import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  confirm() {
    if (!window.confirm("Supprimer la photo de ce produit ?")) return

    const flag = document.querySelector("[data-photo-delete-target='flag']")
    if (flag) flag.value = "1"

    this.element.closest(".edit-current-photo").remove()
  }
}
