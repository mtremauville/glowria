// app/javascript/controllers/composition_scanner_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput", "cameraView", "video", "canvas",
    "preview", "previewImg", "analyzeBtn",
    "status", "result", "ingredientsList", "ingredientsCount",
    "nameInput", "brandInput", "submitSection"
  ]

  static values = { scanUrl: String }

  connect() {
    this.stream       = null
    this.capturedBlob = null
  }

  disconnect() {
    this.stopStream()
  }

  // ── Caméra getUserMedia ─────────────────────────────────────────
  async openCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment", width: { ideal: 1280 } }
      })
      this.videoTarget.srcObject = this.stream
      await this.videoTarget.play()
      this.cameraViewTarget.hidden = false
      this.setStatus("loading", "Pointe la caméra vers la liste d'ingrédients…")
    } catch (err) {
      // Fallback : ouvre l'explorateur de fichiers
      this.fileInputTarget.click()
    }
  }

  closeCamera() {
    this.stopStream()
    this.cameraViewTarget.hidden = true
    this.setStatus("", "")
  }

  capturePhoto() {
    const video  = this.videoTarget
    const canvas = this.canvasTarget

    canvas.width  = video.videoWidth
    canvas.height = video.videoHeight
    canvas.getContext("2d").drawImage(video, 0, 0)

    this.stopStream()
    this.cameraViewTarget.hidden = true

    canvas.toBlob(blob => {
      this.capturedBlob = blob
      const url = URL.createObjectURL(blob)
      this.previewImgTarget.src = url
      this.previewTarget.hidden = false
      this.analyzeBtnTarget.disabled = false
      this.resultTarget.hidden = true
      this.submitSectionTarget.hidden = true
      this.setStatus("", "")
    }, "image/jpeg", 0.92)
  }

  stopStream() {
    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
    }
  }

  // ── Fallback : sélection depuis les fichiers ────────────────────
  onFileSelected(event) {
    const file = event.target.files[0]
    if (!file) return

    this.capturedBlob = file
    const url = URL.createObjectURL(file)
    this.previewImgTarget.src = url
    this.previewTarget.hidden = false
    this.analyzeBtnTarget.disabled = false
    this.resultTarget.hidden = true
    this.submitSectionTarget.hidden = true
    this.setStatus("", "")
  }

  // ── Envoi au serveur pour analyse IA ────────────────────────────
  async analyze() {
    const file = this.capturedBlob
    if (!file) return

    this.analyzeBtnTarget.disabled = true
    this.setStatus("loading", "Analyse en cours…")
    this.resultTarget.hidden = true
    this.submitSectionTarget.hidden = true

    const formData = new FormData()
    formData.append("image", file, "photo.jpg")

    try {
      const resp = await fetch(this.scanUrlValue, {
        method: "POST",
        body: formData,
        headers: { "X-CSRF-Token": this.csrfToken() }
      })

      const data = await resp.json()

      if (!resp.ok || !data.success) {
        this.setStatus("error", data.error || "Erreur lors de l'analyse.")
        this.analyzeBtnTarget.disabled = false
        return
      }

      this.displayResult(data)

    } catch (err) {
      this.setStatus("error", "Erreur réseau. Réessaie.")
      this.analyzeBtnTarget.disabled = false
    }
  }

  displayResult(data) {
    if (data.product_name && this.hasNameInputTarget) {
      this.nameInputTarget.value = data.product_name
    }
    if (data.brand && this.hasBrandInputTarget) {
      this.brandInputTarget.value = data.brand
    }

    if (data.ingredients && data.ingredients.length > 0) {
      this.ingredientsCountTarget.textContent =
        `${data.count} ingrédient${data.count > 1 ? "s" : ""} détecté${data.count > 1 ? "s" : ""}`

      this.ingredientsListTarget.innerHTML = data.ingredients
        .map((ing, i) => `
          <div class="scan-ing-item">
            <span class="scan-ing-item__pos">${i + 1}</span>
            <span class="scan-ing-item__name">${ing}</span>
          </div>
        `).join("")

      this.setStatus("success", "Composition extraite avec succès.")
      this.resultTarget.hidden = false
      this.submitSectionTarget.hidden = false
      this.injectIngredients(data.ingredients)
    } else {
      this.setStatus("error", "Aucun ingrédient trouvé. Essaie avec une photo plus nette.")
      this.analyzeBtnTarget.disabled = false
    }
  }

  injectIngredients(ingredients) {
    this.element.querySelectorAll("input[name='product[ingredients][]']").forEach(el => el.remove())
    const form = this.element.querySelector("form.composition-form")
    if (!form) return
    ingredients.forEach(ing => {
      const input = document.createElement("input")
      input.type  = "hidden"
      input.name  = "product[ingredients][]"
      input.value = ing
      form.appendChild(input)
    })
  }

  setStatus(type, message) {
    if (!this.hasStatusTarget) return
    this.statusTarget.className = `scan-status ${type ? "scan-status--" + type : ""}`
    this.statusTarget.textContent = message
    this.statusTarget.hidden = !message
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
