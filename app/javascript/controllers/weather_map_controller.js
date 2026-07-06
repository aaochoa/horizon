import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    lat: Number,
    lon: Number,
    name: String,
    temp: String,
    desc: String,
    time: String,
    icon: String,
    unitSymbol: { type: String, default: "°C" }
  }

  connect() {
    this.initMap()
    this.themeChangedListener = this.onThemeChanged.bind(this)
    document.addEventListener("theme-changed", this.themeChangedListener)
  }

  disconnect() {
    this.destroyMap()
    if (this.updateTimeout) clearTimeout(this.updateTimeout)
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
        maxZoom: 20,
        className: "map-tiles"
      }).addTo(this.map)
    }
  }

  initMap() {
    this.destroyMap()

    const lat = this.latValue
    const lon = this.lonValue

    // Initialize Leaflet Map on the canvas target
    this.map = L.map(this.canvasTarget, {
      zoomControl: false,
      scrollWheelZoom: true
    }).setView([lat, lon], 10)

    // Move Zoom controls to bottom-right to avoid overlapping the left sidebar
    L.control.zoom({
      position: 'bottomright'
    }).addTo(this.map)

    const isDark = document.documentElement.classList.contains("dark")
    const tileUrl = isDark 
      ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
      : "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"

    // Theme-themed Map Tiles (CartoDB Dark Matter / Positron)
    this.tileLayer = L.tileLayer(tileUrl, {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 20,
      className: "map-tiles"
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

    // Call lucide.createIcons on popup open
    this.map.on("popupopen", () => {
      if (typeof lucide !== 'undefined') lucide.createIcons()
    })

    // Place Marker
    this.marker = L.marker([lat, lon], { icon: customIcon }).addTo(this.map)

    // Bind Popup with weather status
    const popupContent = this.getPopupContent(lat, lon)
    this.marker.bindPopup(popupContent).openPopup()

    // Bind click listener to select places on click
    this.map.on("click", (e) => {
      const { lat, lng } = e.latlng
      this.selectCoordinates(lat, lng)
    })

    // Ensure Leaflet updates size if the layout is dynamically rendered/resized
    setTimeout(() => {
      if (this.map) {
        this.map.invalidateSize()
      }
    }, 100)
  }

  selectCoordinates(lat, lon) {
    const url = new URL(window.location.origin)
    url.searchParams.set("lat", lat.toFixed(4))
    url.searchParams.set("lon", lon.toFixed(4))

    if (window.Turbo) {
      window.Turbo.visit(url.toString())
    } else {
      window.location.href = url.toString()
    }
  }


  destroyMap() {
    if (this.map) {
      this.map.off()
      this.map.remove()
      this.map = null
    }
  }

  latValueChanged() { this.updateMapPosition() }
  lonValueChanged() { this.updateMapPosition() }
  tempValueChanged() { this.updateMapPosition() }
  nameValueChanged() { this.updateMapPosition() }
  descValueChanged() { this.updateMapPosition() }
  timeValueChanged() { this.updateMapPosition() }
  iconValueChanged() { this.updateMapPosition() }

  getPopupContent(lat, lon) {
    return `
      <div class="p-2 text-slate-900 font-sans">
        <h4 class="font-bold text-sm leading-tight">${this.nameValue}</h4>
        ${this.hasTimeValue ? `<p class="text-sm font-semibold text-slate-500 mt-0.5">${this.timeValue}</p>` : ''}
        <div class="flex items-center gap-1.5 mt-1.5">
          ${this.hasIconValue ? `<i data-lucide="${this.iconValue}" class="w-4 h-4 text-cyan-600 shrink-0"></i>` : ''}
          <span class="text-lg font-extrabold text-slate-800">${this.tempValue}${this.unitSymbolValue}</span>
          <span class="text-xs font-semibold px-1.5 py-0.5 rounded bg-cyan-100 text-cyan-800">${this.descValue}</span>
        </div>
        <p class="text-[10px] text-slate-400 mt-1">Coordinates: ${lat.toFixed(4)}, ${lon.toFixed(4)}</p>
      </div>
    `
  }

  updateMapPosition() {
    if (this.map && this.marker) {
      if (this.updateTimeout) clearTimeout(this.updateTimeout)
      this.updateTimeout = setTimeout(() => {
        const lat = this.latValue
        const lon = this.lonValue

        // Smooth pan map to new coordinates
        this.map.panTo([lat, lon])
        this.marker.setLatLng([lat, lon])

        const popupContent = this.getPopupContent(lat, lon)
        this.marker.setPopupContent(popupContent)
        if (typeof lucide !== 'undefined') lucide.createIcons()

        const markerElement = this.marker.getElement()
        if (markerElement) {
          const tempSpan = markerElement.querySelector('span.relative')
          if (tempSpan) {
            tempSpan.textContent = `${Math.round(parseFloat(this.tempValue))}°`
          }
        }
      }, 50)
    }
  }
}
