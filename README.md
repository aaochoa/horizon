# Horizon Weather

Horizon Weather is a modern, high-performance, glassmorphic Ruby on Rails 8 weather application. It provides real-time weather forecasts, interactive mapping, auto-complete search functionality, and personalized favorite locations, all powered by standard Rails Hotwire and Tailwind CSS v4.

---

## 🌟 Key Features

- **Keyless API Integration**: Retrieves weather forecasts and geocoding details using keyless endpoints from **Open-Meteo**, making setup instantaneous.
- **Hotwire Architecture**: Utilizes **Turbo Drive, Turbo Frames, and Stimulus JS** for real-time partial page updates and smooth, SPA-like responsiveness. Scopes frame reloads strictly to the weather details, keeping the map and search bar active and untouched.
- **Resilient Service Layer**: Gracefully handles network timeouts (`Net::OpenTimeout`) and API failures by returning rich, structured mock fallback weather data to ensure the UI remains fully functional offline or during local development demos.
- **Smart Caching**: Implements custom caching to minimize external API hits:
  - Weather forecasts cached for **15 minutes**.
  - Autocomplete location results cached for **1 day**.
  - Reverse geocoding cached for **30 days** using Solid Cache.
  - Fully supports manual force refreshes when requested.
- **Interactive Weather Map**: Uses **Leaflet.js** and OpenStreetMap to display geographic weather visualizers. It features:
  - **Full-Screen Desktop Mode**: A Google Maps-style fullscreen layout with floating glassmorphic weather cards.
  - **Interactive Selection**: Click anywhere on the map to instantly select coordinates and reload the local weather.
  - **Map-Level Geolocation**: A floating crosshair "Locate Me" button to retrieve and load the user's current coordinates.
- **Geocoding & Local Time**:
  - Automatically reverse-geocodes coordinates into English location names (e.g. "Seoul, South Korea") using OpenStreetMap's **Nominatim API** (with a custom User-Agent).
  - Timezone-aware local time and date rendering in both the sidebar location header and the map marker popup tooltip.
  - Aligns the hourly forecast to start exactly from the city's current local hour and highlights the current hour card as **Now**.
- **Dynamic Light/Dark Theme**: A fully custom theme toggler built with Tailwind CSS v4 custom variants (`@custom-variant dark`) and a persistent Stimulus controller.

---

## 🛠️ Tech Stack

- **Core**: Ruby on Rails 8 (with default modern security features)
- **Database**: PostgreSQL
- **Caching & Jobs**: Solid Cache & Solid Queue
- **Styling**: Tailwind CSS v4 with custom dark-mode selectors
- **Icons**: Lucide Icons (rendered dynamically via Stimulus and reloaded on Turbo frame renders)
- **Frontend Interaction**: Hotwire (Turbo + Stimulus) & Leaflet.js
- **Testing**: Minitest with customized API stubbing

---

## 🚀 Getting Started

### 📋 Prerequisites

Ensure you have the following installed on your local system:
- **Ruby**: `3.4.9` (as defined in [.ruby-version](file:///.ruby-version))
- **PostgreSQL** database engine

### 💻 Setup

1. **Automated Setup**
   The application includes an idempotent setup script that installs dependencies, prepares the database, clears logs, and boots up the development server:
   ```bash
   bin/setup
   ```

2. **Manual Setup**
   If you prefer to run steps manually:
   ```bash
   # Install Ruby gems
   bundle install

   # Setup the database (creates database, loads schema)
   bin/rails db:prepare

   # Start the development server and Tailwind watcher
   bin/dev
   ```

---

## 📂 Project Structure

- [WeatherService](file:///Users/anderson/Documents/dev/horizon/app/services/weather_service.rb): Core service managing Open-Meteo connections, Nominatim reverse geocoding lookups, fallback demo generation, and rails caching policies.
- [WeatherController](file:///Users/anderson/Documents/dev/horizon/app/controllers/weather_controller.rb): Manages the main forecast index view, coordinates checks, and routes autocomplete search results.
- **Stimulus Controllers** ([app/javascript/controllers](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers)):
  - [theme_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/theme_controller.js): Handles light/dark mode toggling with dynamic icon updating.
  - [autocomplete_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/autocomplete_controller.js): Powers the search autocomplete dropdown for global cities.
  - [weather_map_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/weather_map_controller.js): Initializes the interactive Leaflet map and updates it in-place using Stimulus value change callbacks.
  - [local_time_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/local_time_controller.js): Formats the "Updated" forecast timestamp in the user's browser local system time.
  - [map_locate_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/map_locate_controller.js): Manages the floating GPS button geolocating actions.
  - [refresh_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/refresh_controller.js): Triggers periodic checks for only the weather cards without reloading the map or search bar.

---

## 🧪 Running the Test Suite

This project includes functional and unit Minitest suites verifying all controllers, models, and services. In compliance with network resilience guidelines, tests do not make actual HTTP requests and instead stub API calls:

```bash
bin/rails test
```
