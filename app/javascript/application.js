// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// ── Modal de confirmation personnalisé (remplace window.confirm) ──
Turbo.config.forms.confirm = (message) => {
  return new Promise((resolve) => {
    const dialog    = document.getElementById("turbo-confirm-dialog")
    const msgEl     = document.getElementById("confirm-dialog-message")
    const btnOk     = document.getElementById("confirm-dialog-confirm")
    const btnCancel = document.getElementById("confirm-dialog-cancel")

    if (!dialog) { resolve(window.confirm(message)); return }

    // Variante rouge pour les suppressions
    const isDanger = /supprim|retirer|effacer|supprimer/i.test(message)
    dialog.classList.toggle("confirm-dialog--danger", isDanger)

    msgEl.textContent = message
    dialog.showModal()

    const cleanup = (result) => {
      dialog.close()
      btnOk.removeEventListener("click", onOk)
      btnCancel.removeEventListener("click", onCancel)
      resolve(result)
    }
    const onOk     = () => cleanup(true)
    const onCancel = () => cleanup(false)

    btnOk.addEventListener("click", onOk)
    btnCancel.addEventListener("click", onCancel)

    // Clic sur le backdrop = annuler
    dialog.addEventListener("click", function onBackdrop(e) {
      if (e.target === dialog) { cleanup(false); dialog.removeEventListener("click", onBackdrop) }
    })
  })
}

// ── Navbar burger menu (event delegation — Turbo compatible) ──
function closeDrawer() {
  document.getElementById('navbar-drawer')?.classList.remove('open');
  document.getElementById('navbar-overlay')?.classList.remove('open');
  const icon = document.getElementById('burger-icon');
  icon?.classList.replace('fa-xmark', 'fa-bars');
  document.getElementById('navbar-burger')?.setAttribute('aria-expanded', 'false');
}

document.addEventListener('click', (e) => {
  if (e.target.closest('#navbar-burger')) {
    const drawer  = document.getElementById('navbar-drawer');
    const overlay = document.getElementById('navbar-overlay');
    const icon    = document.getElementById('burger-icon');
    const burger  = document.getElementById('navbar-burger');
    const isOpen  = drawer?.classList.toggle('open');
    overlay?.classList.toggle('open');
    icon?.classList.replace(isOpen ? 'fa-bars' : 'fa-xmark', isOpen ? 'fa-xmark' : 'fa-bars');
    burger?.setAttribute('aria-expanded', String(isOpen));
    return;
  }
  if (e.target.closest('#navbar-overlay')) {
    closeDrawer();
  }
});

document.addEventListener('turbo:before-visit', closeDrawer);

// ── Auto-dismiss des toasts après 3 secondes ──
function initToasts() {
  document.querySelectorAll('.glow-toast').forEach(toast => {
    if (toast.dataset.toastInit) return
    toast.dataset.toastInit = "1"
    setTimeout(() => {
      toast.classList.add('toast-hiding')
      toast.addEventListener('animationend', () => toast.remove(), { once: true })
    }, 3000)
  })
}
document.addEventListener('turbo:load', initToasts)
document.addEventListener('DOMContentLoaded', initToasts)

// PWA Service Worker registration
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker")
      .catch((err) => console.error("Service worker registration failed:", err))
  })
}
