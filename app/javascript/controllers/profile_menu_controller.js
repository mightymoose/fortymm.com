import { Controller } from "@hotwired/stimulus"

const enteringAnimation = {
  active: ["transition", "ease-out", "duration-100"],
  from: ["transform", "opacity-0", "scale-95"],
  to: ["opacity-100", "scale-100"]
}

const leavingAnimation = {
  active: ["transition", "ease-in", "duration-75"],
  from: ["opacity-100", "scale-100"],
  to: ["transform", "opacity-0", "scale-95"]
}

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    this.open = false;
    this.menuTarget.addEventListener("click", e => e.stopPropagation())
  }

  openMenu() {
    this.open = true;

    this.menuTarget.classList.add(...enteringAnimation.active);
    this.menuTarget.classList.add(...enteringAnimation.from);
    this.menuTarget.classList.remove("hidden");

    requestAnimationFrame(() => {
      this.menuTarget.classList.remove(...enteringAnimation.from);
      this.menuTarget.classList.add(...enteringAnimation.to);
    });
  }

  closeMenu() {
    this.open = false;

    this.menuTarget.addEventListener('transitionend', () => {
      this.menuTarget.classList.add("hidden");
    }, { once: true });

    this.menuTarget.classList.add(...leavingAnimation.active);
    this.menuTarget.classList.add(...leavingAnimation.from);

    requestAnimationFrame(() => {
      this.menuTarget.classList.remove(...leavingAnimation.from);
      this.menuTarget.classList.add(...leavingAnimation.to);
    });

  }

  toggle() {
    this.open ? this.closeMenu() : this.openMenu();
  }

  get isBeingRendered() {
    return this.hasMenu
  }

  disconnect() {
    this.isBeingRendered && this.closeMenu();
  }
}
