import { Controller } from "@hotwired/stimulus"

// Cible les éléments du DOM :
//   input      → champ texte code-barre
//   preview    → carte produit trouvé
//   feedback   → message status
//   submit     → bouton "Ajouter"
//   cameraBtn  → bouton "Scanner avec la caméra"
//   cameraView → conteneur vidéo
//   video      → élément <video>
//   overlay    → cadre de visée

export default class extends Controller {
  static targets = ["input", "preview", "submit", "feedback",
                    "cameraBtn", "cameraView", "video", "overlay"]
  static values  = { lookupUrl: String }

  connect() {
    this.debounceTimer    = null
    this.stream           = null
    this.scanAnimFrame    = null
    this.scanning         = false
    this.lastBarcode      = null

    // BarcodeDetector natif (Chrome 83+, Edge 83+, Safari 17.4+)
    if ("BarcodeDetector" in window) {
      this.detector = new BarcodeDetector({
        formats: ["ean_13", "ean_8", "upc_a", "upc_e", "code_128"]
      })
    } else {
      this.detector = null
    }
  }

  disconnect() {
    this.stopCamera()
  }

  // ── Saisie manuelle (input) ──────────────────────────────────────
  lookup() {
    const barcode = this.inputTarget.value.trim()
    if (!/^\d{8}$|^\d{13}$/.test(barcode)) return

    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.fetchProduct(barcode), 400)
  }

  // ── Caméra ──────────────────────────────────────────────────────
  async toggleCamera() {
    if (this.scanning) {
      this.stopCamera()
    } else {
      await this.startCamera()
    }
  }

  async startCamera() {
    if (!this.detector) {
      this.setFeedback("error",
        "Scanner non disponible sur ce navigateur. Saisis le code-barre manuellement.")
      return
    }

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment", width: { ideal: 1280 } }
      })

      this.videoTarget.srcObject = this.stream
      await this.videoTarget.play()

      this.cameraViewTarget.hidden = false
      this.cameraBtnTarget.textContent = "✕ Fermer la caméra"
      this.scanning = true
      this.lastBarcode = null

      this.setFeedback("loading", "Pointe la caméra vers le code-barre…")
      this.scanLoop()

    } catch (err) {
      const msg = err.name === "NotAllowedError"
        ? "Accès à la caméra refusé. Autorise-la dans les réglages."
        : "Impossible d'ouvrir la caméra."
      this.setFeedback("error", msg)
    }
  }

  stopCamera() {
    this.scanning = false
    cancelAnimationFrame(this.scanAnimFrame)

    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
    }

    if (this.hasCameraViewTarget) this.cameraViewTarget.hidden = true
    if (this.hasCameraBtnTarget)  this.cameraBtnTarget.textContent = "📷 Scanner avec la caméra"
  }

  scanLoop() {
    if (!this.scanning) return

    this.scanAnimFrame = requestAnimationFrame(async () => {
      if (!this.scanning) return

      try {
        const barcodes = await this.detector.detect(this.videoTarget)
        if (barcodes.length > 0) {
          const code = barcodes[0].rawValue

          // Dédoublonnage : on n'envoie pas deux fois le même code
          if (code !== this.lastBarcode) {
            this.lastBarcode = code
            this.flashOverlay()
            this.stopCamera()
            this.inputTarget.value = code
            await this.fetchProduct(code)
          }
        }
      } catch { /* frame non lisible, on continue */ }

      if (this.scanning) this.scanLoop()
    })
  }

  flashOverlay() {
    if (!this.hasOverlayTarget) return
    this.overlayTarget.classList.add("scan-overlay--hit")
    setTimeout(() => this.overlayTarget.classList.remove("scan-overlay--hit"), 400)
  }

  // ── Lookup API ───────────────────────────────────────────────────
  async fetchProduct(barcode) {
    this.setFeedback("loading", "Recherche en cours…")
    this.previewTarget.innerHTML = ""
    this.submitTarget.disabled = true

    try {
      const res = await fetch(`${this.lookupUrlValue}?barcode=${barcode}`, {
        headers: { "Accept": "application/json" }
      })

      if (!res.ok) {
        this.setFeedback("error",
          "Produit introuvable dans la base. Tu peux l'ajouter manuellement ci-dessous.")
        return
      }

      const data = await res.json()
      this.displayPreview(data, barcode)

    } catch {
      this.setFeedback("error", "Erreur réseau. Vérifie ta connexion.")
    }
  }

  displayPreview(data, barcode) {
    const imgHtml = data.image_url
      ? `<img src="${data.image_url}" alt="${data.name}" class="product-thumb">`
      : `<div class="product-thumb-placeholder">🧴</div>`

    const ingredientsHtml = (data.ingredients || []).length
      ? `<p class="ingredients-preview">
           ${(data.ingredients).slice(0, 5).join(" · ")}
           ${data.ingredients.length > 5 ? `<em>+ ${data.ingredients.length - 5} autres</em>` : ""}
         </p>`
      : `<p class="ingredients-preview text-muted">Aucun ingrédient listé</p>`

    this.previewTarget.innerHTML = `
      <div class="product-preview">
        ${imgHtml}
        <div class="product-preview__info">
          <strong style="font-size:14px">${data.name}</strong>
          <span class="text-muted" style="font-size:12px">${data.brand || ""}</span>
          <span class="badge-category">${data.category}</span>
          ${ingredientsHtml}
        </div>
      </div>
    `

    document.getElementById("barcode_hidden").value = barcode
    this.feedbackTarget.innerHTML = `
      <p class="scan-found">✓ Produit identifié — clique sur "Ajouter à ma collection"</p>
    `
    this.submitTarget.disabled = false
  }

  setFeedback(type, message) {
    const cls = { loading: "scan-loading", error: "scan-error" }
    this.feedbackTarget.innerHTML = `<p class="${cls[type]}">${message}</p>`
    if (type === "error") {
      this.previewTarget.innerHTML = ""
      this.submitTarget.disabled = true
    }
  }
}
