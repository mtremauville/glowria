import { Controller } from "@hotwired/stimulus"

// Targets :
//   cameraBtn  → bouton "Prendre une photo" / "Fermer"
//   cameraView → conteneur vidéo live
//   video      → élément <video>
//   canvas     → canvas caché pour la capture
//   preview    → zone d'aperçu après capture
//   previewImg → <img> de l'aperçu
//   fileInput  → <input type="file"> (fallback + injection du blob)

export default class extends Controller {
  static targets = [
    "cameraBtn", "cameraView", "video", "canvas",
    "preview", "previewImg", "fileInput"
  ]

  connect() {
    this.stream = null
  }

  disconnect() {
    this.stopStream()
  }

  // ── Ouvre la caméra ────────────────────────────────────────────
  async openCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment", width: { ideal: 1280 } }
      })
      this.videoTarget.srcObject = this.stream
      await this.videoTarget.play()
      this.cameraViewTarget.hidden = false
      this.previewTarget.hidden    = true
      this.cameraBtnTarget.innerHTML =
        '<i class="fa-solid fa-xmark"></i><span>Annuler</span>'
    } catch (_err) {
      // Fallback : sélection depuis la galerie
      this.fileInputTarget.click()
    }
  }

  // ── Ferme la caméra sans capturer ──────────────────────────────
  closeCamera() {
    this.stopStream()
    this.cameraViewTarget.hidden = true
    this.cameraBtnTarget.innerHTML =
      '<i class="fa-solid fa-camera"></i><span>Prendre une photo</span>'
  }

  // ── Capture le frame courant ───────────────────────────────────
  capture() {
    const video  = this.videoTarget
    const canvas = this.canvasTarget
    canvas.width  = video.videoWidth
    canvas.height = video.videoHeight
    canvas.getContext("2d").drawImage(video, 0, 0)

    this.closeCamera()

    canvas.toBlob(blob => {
      // Injecte le blob dans le file input pour que le formulaire l'envoie
      const file = new File([blob], "photo.jpg", { type: "image/jpeg" })
      const dt   = new DataTransfer()
      dt.items.add(file)
      this.fileInputTarget.files = dt.files

      // Affiche l'aperçu
      this.previewImgTarget.src = URL.createObjectURL(blob)
      this.previewTarget.hidden = false

      this.cameraBtnTarget.innerHTML =
        '<i class="fa-solid fa-rotate"></i><span>Reprendre</span>'
    }, "image/jpeg", 0.92)
  }

  // ── Fallback fichier ───────────────────────────────────────────
  onFileSelected(event) {
    const file = event.target.files[0]
    if (!file) return
    this.previewImgTarget.src = URL.createObjectURL(file)
    this.previewTarget.hidden = false
    this.cameraBtnTarget.innerHTML =
      '<i class="fa-solid fa-rotate"></i><span>Reprendre</span>'
  }

  // ── Supprime la photo ──────────────────────────────────────────
  remove() {
    this.fileInputTarget.value   = ""
    this.previewTarget.hidden    = true
    this.cameraBtnTarget.innerHTML =
      '<i class="fa-solid fa-camera"></i><span>Prendre une photo</span>'
  }

  stopStream() {
    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
    }
  }
}
