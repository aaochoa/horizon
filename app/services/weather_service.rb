require "net/http"
require "json"

class WeatherService
  CACHE_EXPIRATION = 15.minutes
  GEOCODE_CACHE_EXPIRATION = 1.day

  class << self
    def get_weather(lat, lon, force_refresh: false)
      cache_key = "weather_forecast_#{lat}_#{lon}"
      
      if force_refresh
        Rails.cache.delete(cache_key)
      end

      data = Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
        fetch_weather_from_api(lat, lon)
      end

      data || fallback_weather_data(lat, lon)
    rescue => e
      Rails.logger.error "WeatherService error: #{e.message}"
      fallback_weather_data(lat, lon)
    end

    def search_cities(query)
      return [] if query.blank?

      cache_key = "city_search_#{query.parameterize}"
      data = Rails.cache.fetch(cache_key, expires_in: GEOCODE_CACHE_EXPIRATION) do
        fetch_cities_from_api(query)
      end

      data.presence || fallback_cities(query)
    rescue => e
      Rails.logger.error "WeatherService geocoding error: #{e.message}"
      fallback_cities(query)
    end

    def weather_info(code)
      # WMO Weather interpretation codes (WMOCodes)
      case code
      when 0
        { description: "Clear Sky", icon: "sun" }
      when 1
        { description: "Mainly Clear", icon: "cloud-sun" }
      when 2
        { description: "Partly Cloudy", icon: "cloud" }
      when 3
        { description: "Overcast", icon: "clouds" }
      when 45, 48
        { description: "Foggy", icon: "cloud-fog" }
      when 51, 53, 55
        { description: "Drizzle", icon: "cloud-drizzle" }
      when 56, 57
        { description: "Freezing Drizzle", icon: "cloud-snow" }
      when 61, 63, 65
        { description: "Rainy", icon: "cloud-rain" }
      when 66, 67
        { description: "Freezing Rain", icon: "cloud-snow" }
      when 71, 73, 75
        { description: "Snowy", icon: "cloud-snow" }
      when 77
        { description: "Snow Grains", icon: "cloud-snow" }
      when 80, 81, 82
        { description: "Rain Showers", icon: "cloud-lightning-rain" }
      when 85, 86
        { description: "Snow Showers", icon: "cloud-snow" }
      when 95, 96, 99
        { description: "Thunderstorm", icon: "cloud-lightning" }
      else
        { description: "Unknown", icon: "help" }
      end
    end

    def moon_phase_details(phase_value)
      phase_value = phase_value.to_f
      
      if phase_value == 0 || phase_value == 1
        name = "New Moon"
        emoji = "🌑"
      elsif phase_value > 0 && phase_value < 0.25
        name = "Waxing Crescent"
        emoji = "🌒"
      elsif phase_value == 0.25
        name = "First Quarter"
        emoji = "🌓"
      elsif phase_value > 0.25 && phase_value < 0.5
        name = "Waxing Gibbous"
        emoji = "🌔"
      elsif phase_value == 0.5
        name = "Full Moon"
        emoji = "🌕"
      elsif phase_value > 0.5 && phase_value < 0.75
        name = "Waning Gibbous"
        emoji = "🌖"
      elsif phase_value == 0.75
        name = "Third Quarter"
        emoji = "🌗"
      else
        name = "Waning Crescent"
        emoji = "🌘"
      end
      
      illumination = if phase_value <= 0.5
        (phase_value * 2 * 100).round
      else
        ((1 - phase_value) * 2 * 100).round
      end
      
      { name: name, emoji: emoji, illumination: illumination }
    end

    private

    def fetch_weather_from_api(lat, lon)
      url = "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,wind_speed_10m&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,sunrise,sunset,moonrise,moonset,moon_phase&timezone=auto"
      
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        Rails.logger.error "Open-Meteo API failure: #{response.code} #{response.message}"
        nil
      end
    end

    def fetch_cities_from_api(query)
      escaped_query = CGI.escape(query)
      url = "https://geocoding-api.open-meteo.com/v1/search?name=#{escaped_query}&count=8&language=en&format=json"
      
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        results = data["results"] || []
        results.map do |city|
          {
            name: [city["name"], city["admin1"], city["country"]].compact.join(", "),
            latitude: city["latitude"],
            longitude: city["longitude"],
            country: city["country"],
            country_code: city["country_code"]
          }
        end
      else
        Rails.logger.error "Open-Meteo Geocoding API failure: #{response.code} #{response.message}"
        []
      end
    end

    def fallback_weather_data(lat, lon)
      {
        "latitude" => lat,
        "longitude" => lon,
        "current" => {
          "temperature_2m" => 21.5,
          "relative_humidity_2m" => 64,
          "apparent_temperature" => 20.8,
          "is_day" => 1,
          "precipitation" => 0.0,
          "rain" => 0.0,
          "showers" => 0.0,
          "snowfall" => 0.0,
          "weather_code" => 2, # Partly Cloudy
          "wind_speed_10m" => 12.5
        },
        "hourly" => {
          "time" => Array.new(24) { |i| (Time.current + i.hours).strftime("%Y-%m-%dT%H:00") },
          "temperature_2m" => Array.new(24) { |i| 21.5 + Math.sin(i / 3.0) * 3 },
          "precipitation_probability" => Array.new(24) { |i| [0, 10, 20, 30][i % 4] },
          "weather_code" => Array.new(24) { 2 }
        },
        "daily" => {
          "time" => Array.new(7) { |i| (Date.current + i.days).strftime("%Y-%m-%d") },
          "weather_code" => [2, 1, 0, 3, 61, 80, 2],
          "temperature_2m_max" => [24, 25, 27, 23, 20, 22, 24],
          "temperature_2m_min" => [15, 16, 17, 14, 12, 13, 15],
          "precipitation_sum" => [0.0, 0.0, 0.0, 0.5, 4.2, 1.8, 0.0],
          "sunrise" => Array.new(7) { |i| (Time.current.beginning_of_day + i.days + 6.hours).strftime("%Y-%m-%dT%H:%M") },
          "sunset" => Array.new(7) { |i| (Time.current.beginning_of_day + i.days + 20.hours).strftime("%Y-%m-%dT%H:%M") },
          "moonrise" => Array.new(7) { |i| (Time.current.beginning_of_day + i.days + 22.hours).strftime("%Y-%m-%dT%H:%M") },
          "moonset" => Array.new(7) { |i| (Time.current.beginning_of_day + i.days + 8.hours).strftime("%Y-%m-%dT%H:%M") },
          "moon_phase" => [0.1, 0.25, 0.4, 0.5, 0.65, 0.8, 0.95]
        },
        "is_fallback" => true
      }
    end

    def fallback_cities(query)
      [
        { name: "Chicago, Illinois, United States", latitude: 41.8781, longitude: -87.6298, country: "United States", country_code: "US" },
        { name: "New York, New York, United States", latitude: 40.7128, longitude: -74.0060, country: "United States", country_code: "US" },
        { name: "London, England, United Kingdom", latitude: 51.5074, longitude: -0.1278, country: "United Kingdom", country_code: "GB" },
        { name: "Tokyo, Tokyo, Japan", latitude: 35.6762, longitude: 139.6503, country: "Japan", country_code: "JP" }
      ].select { |c| c[:name].downcase.include?(query.downcase) }
    end
  end
end
