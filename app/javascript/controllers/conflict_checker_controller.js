import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn", "label", "spinner"]

  check() {
    this.labelTarget.textContent = "Analyse en cours…"
    this.spinnerTarget.hidden = false
    this.btnTarget.disabled = true
  }
}
