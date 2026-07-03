import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 60000 } // 60 seconds default
  }

  connect() {
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  startTimer() {
    this.stopTimer()
    this.timer = setInterval(() => {
      this.refresh()
    }, this.intervalValue)
  }

  stopTimer() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  refresh() {
    // If the element itself is a turbo-frame, reload it. Otherwise, look for one inside.
    const frame = this.element.tagName === "TURBO-FRAME" ? this.element : this.element.querySelector("turbo-frame")
    if (frame) {
      // We append a custom query param to bypass cache
      const src = new URL(frame.src || window.location.href)
      src.searchParams.set("refresh", "true")
      frame.src = src.toString()
      frame.reload()
    }
  }
}
