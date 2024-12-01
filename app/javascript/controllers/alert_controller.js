import { Controller } from "@hotwired/stimulus"

const enteringAnimation = {
  active: ["transform", "ease-out", "duration-300", "transition"],
  from: ["translate-y-2", "opacity-0", "sm:translate-y-0", "sm:translate-x-2"],
  to: ["translate-y-0", "opacity-100", "sm:translate-x-0"]
};

const leavingAnimation = {
  active: ["transition", "ease-in", "duration-100"],
  from: ["opacity-100"],
  to: ["opacity-0"]
};

export default class extends Controller {
  connect() {
    this.element.classList.add(...enteringAnimation.active);
    this.element.classList.add(...enteringAnimation.from);
    this.element.classList.remove("hidden");

    requestAnimationFrame(() => {
      this.element.classList.remove(...enteringAnimation.from);
      this.element.classList.add(...enteringAnimation.to);
    });

    setTimeout(() => this.close(), 5000);
  }

  close() {
    if (!this.element) {
      return;
    }

    this.element.addEventListener('transitionend', () => {
      this.element.classList.add("hidden");
    }, { once: true });

    this.element.classList.add(...leavingAnimation.active);
    this.element.classList.add(...leavingAnimation.from);

    requestAnimationFrame(() => {
      this.element.classList.remove(...leavingAnimation.from);
      this.element.classList.add(...leavingAnimation.to);
    });
  }
}
