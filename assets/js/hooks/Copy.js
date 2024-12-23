export const Copy = {
  mounted() {
    let { to } = this.el.dataset;
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let text = document.querySelector(to).value
      navigator.clipboard.writeText(text).then(() => {
        const clipboardIcon = this.el.querySelector(".block")
        const checkIcon = this.el.querySelector(".hidden")

        clipboardIcon.classList.add("hidden")
        checkIcon.classList.remove("hidden")

        setTimeout(() => {
          clipboardIcon.classList.remove("hidden")
          checkIcon.classList.add("hidden")
        }, 2000)
      })
    });
  },
}