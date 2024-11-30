import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["openMenuIcon",  "closeMenuIcon", "menu"];

  connect() {
    this.open = false;
  }

  openMenu() {
    this.open = true;
    this.closeMenuIconTarget.classList.remove("hidden");
    this.openMenuIconTarget.classList.add("hidden");
    this.menuTarget.classList.remove("hidden");
  }

  closeMenu() {
    this.open = false;
    this.closeMenuIconTarget.classList.add("hidden");
    this.openMenuIconTarget.classList.remove("hidden");
    this.menuTarget.classList.add("hidden");
  }

  toggle() {
    this.open ? this.closeMenu() : this.openMenu();
  }

  get isBeingRendered() {
    return this.hasCloseMenuIconTarget &&
    this.hasOpenMenuIconTarget &&
    this.hasMenuTarget;
  }

  disconnect() {
    this.isBeingRendered && this.closeMenu();
  }
}
