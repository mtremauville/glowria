import { Controller } from "@hotwired/stimulus"

const MESSAGES = [
  "Analyse de ta collection…",
  "Détection des actifs clés…",
  "Optimisation des combinaisons…",
  "Création de la routine matin…",
  "Création de la routine soir…",
  "Finalisation des conseils IA…",
  "Presque prêt…"
]

export default class extends Controller {
  static targets = ["overlay", "message", "bar", "btn"]

  show(event) {
    this.overlayTarget.hidden = false
    document.body.style.overflow = "hidden"

    if (this.hasBtnTarget) {
      this.btnTarget.disabled = true
    }

    this._msgIndex  = 0
    this._progress  = 0
    this._startTime = Date.now()

    this._updateMessage()
    this._animateBar()
  }

  _updateMessage() {
    if (this._msgIndex >= MESSAGES.length) return
    this.messageTarget.textContent = MESSAGES[this._msgIndex]
    this.messageTarget.classList.remove("routine-loader__msg--in")
    void this.messageTarget.offsetWidth // reflow pour relancer l'animation
    this.messageTarget.classList.add("routine-loader__msg--in")

    this._msgIndex++
    if (this._msgIndex < MESSAGES.length) {
      this._msgTimer = setTimeout(() => this._updateMessage(), 2200)
    }
  }

  _animateBar() {
    // Monte à 90% en ~14s, s'arrête là
    const target    = 90
    const duration  = 14000
    const elapsed   = Date.now() - this._startTime
    const raw       = (elapsed / duration) * target
    this._progress  = Math.min(raw, target)

    this.barTarget.style.width = this._progress + "%"

    if (this._progress < target) {
      this._rafId = requestAnimationFrame(() => this._animateBar())
    }
  }

  disconnect() {
    clearTimeout(this._msgTimer)
    cancelAnimationFrame(this._rafId)
  }
}
