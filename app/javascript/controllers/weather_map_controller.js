import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    lat: Number,
    lon: Number,
    name: String,
    temp: String,
    desc: String
  }

  connect() {
    this.initMap()
    this.themeChangedListener = this.onThemeChanged.bind(this)
    document.addEventListener("theme-changed", this.themeChangedListener)
  }

  disconnect() {
    this.destroyMap()
    document.removeEventListener("theme-changed", this.themeChangedListener)
  }

  onThemeChanged(event) {
    if (this.map && this.tileLayer) {
      this.map.removeLayer(this.tileLayer)
      const isDark = event.detail.theme === "dark"
      const tileUrl = isDark 
        ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        : "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
      
      this.tileLayer = L.tileLayer(tileUrl, {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: "abcd",
        maxZoom: 20
      }).addTo(this.map)
    }
  }

  initMap() {
    this.destroyMap()

    const lat = this.latValue
    const lon = this.lonValue

    // Initialize Leaflet Map
    this.map = L.map(this.element, {
      zoomControl: true,
      scrollWheelZoom: false
    }).setView([lat, lon], 10)

    const isDark = document.documentElement.classList.contains("dark")
    const tileUrl = isDark 
      ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
      : "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"

    // Theme-themed Map Tiles (CartoDB Dark Matter / Positron)
    this.tileLayer = L.tileLayer(tileUrl, {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 20
    }).addTo(this.map)

    // Custom CSS-styled marker for Leaflet
    const markerHtml = `
      <div class="relative flex items-center justify-center">
        <span class="absolute inline-flex h-8 w-8 rounded-full bg-cyan-400/40 animate-ping"></span>
        <span class="relative inline-flex rounded-full h-5 w-5 bg-cyan-500 border-2 border-slate-900 shadow-md flex items-center justify-center text-slate-950 font-bold text-[9px] select-none">
          ${Math.round(parseFloat(this.tempValue))}°
        </span>
      </div>
    `

    const customIcon = L.divIcon({
      html: markerHtml,
      className: 'custom-map-marker',
      iconSize: [32, 32],
      iconAnchor: [16, 16],
      popupAnchor: [0, -10]
    })

    // Place Marker
    this.marker = L.marker([lat, lon], { icon: customIcon }).addTo(this.map)

    // Bind Popup with weather status
    const popupContent = `
      <div class="p-2 text-slate-900 font-sans">
        <h4 class="font-bold text-sm leading-tight">${this.nameValue}</h4>
        <div class="flex items-center gap-1.5 mt-1">
          <span class="text-lg font-extrabold text-slate-800">${this.tempValue}°C</span>
          <span class="text-xs font-semibold px-1.5 py-0.5 rounded bg-cyan-100 text-cyan-800">${this.descValue}</span>
        </div>
        <p class="text-[10px] text-slate-500 mt-1">Coordinates: ${lat.toFixed(4)}, ${lon.toFixed(4)}</p>
      </div>
    `

    this.marker.bindPopup(popupContent).openPopup()
  }

  destroyMap() {
    if (this.map) {
      this.map.off()
      this.map.remove()
      this.map = null
    }
  }
}
