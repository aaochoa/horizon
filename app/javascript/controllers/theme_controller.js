import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "lightIcon", "darkIcon" ]

  connect() {
    this.applyTheme()
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    localStorage.setItem("theme", newTheme)
    this.applyTheme()
    
    // Dispatch a custom event so other components (like Leaflet map) can update
    const event = new CustomEvent("theme-changed", { detail: { theme: newTheme } })
    document.dispatchEvent(event)
  }

  getCurrentTheme() {
    if (localStorage.getItem("theme")) {
      return localStorage.getItem("theme")
    }
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  applyTheme() {
    const theme = localStorage.getItem("theme") || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
    
    if (theme === "dark") {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
    
    this.updateIcons(theme)
  }

  updateIcons(theme) {
    const lightIcon = this.element.querySelector('[data-theme-target="lightIcon"]')
    const darkIcon = this.element.querySelector('[data-theme-target="darkIcon"]')

    if (theme === "dark") {
      // In dark theme, we want to show the Sun icon (to switch to light)
      if (lightIcon) lightIcon.classList.remove("hidden")
      if (darkIcon) darkIcon.classList.add("hidden")
    } else {
      // In light theme, we want to show the Moon icon (to switch to dark)
      if (lightIcon) lightIcon.classList.add("hidden")
      if (darkIcon) darkIcon.classList.remove("hidden")
    }
  }
}
