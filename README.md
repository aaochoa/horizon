---
title: Horizon Weather
emoji: 🌤️
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 7860
pinned: false
---

# Horizon Weather

Horizon Weather is a modern, high-performance, glassmorphic Ruby on Rails 8 weather application. It provides real-time weather forecasts, interactive mapping, auto-complete search functionality, and personalized favorite locations, all powered by standard Rails Hotwire and Tailwind CSS v4.

---

## 🌟 Key Features

- **Keyless API Integration**: Retrieves weather forecasts and geocoding details using keyless endpoints from **Open-Meteo**, making setup instantaneous.
- **Hotwire Architecture**: Utilizes **Turbo Drive, Turbo Frames, and Stimulus JS** for real-time partial page updates and smooth, SPA-like responsiveness without the overhead of heavy JavaScript frameworks.
- **Resilient Service Layer**: Gracefully handles network timeouts (`Net::OpenTimeout`) and API failures by returning rich, structured mock fallback weather data to ensure the UI remains fully functional offline or during local development demos.
- **Smart Caching**: Implements custom caching to minimize external API hits:
  - Weather forecasts cached for **15 minutes**.
  - Autocomplete location results cached for **1 day**.
  - Fully supports manual force refreshes when requested.
- **Interactive Weather Map**: Uses **Leaflet.js** and OpenStreetMap to display geographic weather visualizers.
- **Dynamic Light/Dark Theme**: A fully custom theme toggler built with Tailwind CSS v4 custom variants (`@custom-variant dark`) and a persistent Stimulus controller.
- **Secure Authentication & Favorites**: Registered users can save their preferred cities to a personalized dashboard, updating instantly via Turbo Streams.

---

## 🛠️ Tech Stack

- **Core**: Ruby on Rails 8 (with default modern security features)
- **Database**: PostgreSQL
- **Caching & Jobs**: Solid Cache & Solid Queue
- **Styling**: Tailwind CSS v4 with custom dark-mode selectors
- **Icons**: Lucide Icons (rendered dynamically via Stimulus)
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

- [WeatherService](file:///Users/anderson/Documents/dev/horizon/app/services/weather_service.rb): Core service managing Open-Meteo connections, geocoding lookups, fallback demo generation, and rails caching policies.
- [WeatherController](file:///Users/anderson/Documents/dev/horizon/app/controllers/weather_controller.rb): Manages the main forecast index view, coordinates checks, and routes autocomplete search results.
- **Stimulus Controllers** ([app/javascript/controllers](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers)):
  - [theme_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/theme_controller.js): Handles glassmorphic light/dark mode toggling and standard localStorage persistence.
  - [autocomplete_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/autocomplete_controller.js): powers the search autocomplete dropdown for global cities.
  - [weather_map_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/weather_map_controller.js): Initializes the interactive Leaflet map layer for the current coordinates.
  - [refresh_controller.js](file:///Users/anderson/Documents/dev/horizon/app/javascript/controllers/refresh_controller.js): Triggers periodic checks and forced refresh operations.

---

## 🧪 Running the Test Suite

This project includes functional and unit Minitest suites verifying all controllers, models, and services. In compliance with network resilience guidelines, tests do not make actual HTTP requests and instead stub API calls:

```bash
bin/rails test
```
