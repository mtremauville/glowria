// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

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

// PWA Service Worker registration
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker")
      .catch((err) => console.error("Service worker registration failed:", err))
  })
}
