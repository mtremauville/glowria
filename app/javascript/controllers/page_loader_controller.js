import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    document.addEventListener("turbo:load",   () => this.hide())
    document.addEventListener("turbo:render",  () => this.hide())
  }

  show() {
    this.overlayTarget.removeAttribute("hidden")
  }

  hide() {
    this.overlayTarget.setAttribute("hidden", "")
  }
}
