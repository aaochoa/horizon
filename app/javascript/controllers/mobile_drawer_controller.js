import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "backdrop"]

  connect() {
    this.close()
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  open(event) {
    if (event) event.preventDefault()

    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("-translate-x-full")
      this.drawerTarget.classList.add("translate-x-0")
    }

    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
      this.backdropTarget.classList.add("opacity-100", "pointer-events-auto")
    }

    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    if (event) event.preventDefault()

    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("translate-x-0")
      this.drawerTarget.classList.add("-translate-x-full")
    }

    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("opacity-100", "pointer-events-auto")
      this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
    }

    document.body.classList.remove("overflow-hidden")
  }

  toggle(event) {
    if (event) event.preventDefault()

    if (this.hasDrawerTarget) {
      if (this.drawerTarget.classList.contains("-translate-x-full")) {
        this.open()
      } else {
        this.close()
      }
    }
  }
}
