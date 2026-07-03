import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    utc: String
  }

  connect() {
    const date = new Date(this.utcValue)
    if (!isNaN(date.getTime())) {
      const hours = String(date.getHours()).padStart(2, '0')
      const minutes = String(date.getMinutes()).padStart(2, '0')
      const seconds = String(date.getSeconds()).padStart(2, '0')
      this.element.textContent = `${hours}:${minutes}:${seconds}`
    }
  }
}
