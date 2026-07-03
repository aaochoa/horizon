require "test_helper"

class WeatherServiceTest < ActiveSupport::TestCase
  test "weather_info returns appropriate details for WMO codes" do
    clear_sky = WeatherService.weather_info(0)
    assert_equal "Clear Sky", clear_sky[:description]
    assert_equal "sun", clear_sky[:icon]

    thunderstorm = WeatherService.weather_info(95)
    assert_equal "Thunderstorm", thunderstorm[:description]
    assert_equal "cloud-lightning", thunderstorm[:icon]

    unknown = WeatherService.weather_info(999)
    assert_equal "Unknown", unknown[:description]
    assert_equal "help-circle", unknown[:icon]
  end

  test "get_weather fetches and returns weather data" do
    class << WeatherService
      alias_method :original_fetch_weather, :fetch_weather_from_api
      def fetch_weather_from_api(lat, lon)
        { "current" => { "temperature_2m" => 22.5 } }
      end
    end
    
    begin
      result = WeatherService.get_weather(41.8781, -87.6298, force_refresh: true)
      assert_equal 22.5, result["current"]["temperature_2m"]
    ensure
      class << WeatherService
        alias_method :fetch_weather_from_api, :original_fetch_weather
        remove_method :original_fetch_weather
      end
    end
  end

  test "search_cities returns list of matches" do
    class << WeatherService
      alias_method :original_fetch_cities, :fetch_cities_from_api
      def fetch_cities_from_api(query)
        [ { name: "Chicago, IL, USA", latitude: 41.8781, longitude: -87.6298, country: "USA", country_code: "US" } ]
      end
    end

    begin
      results = WeatherService.search_cities("Chicago")
      assert_equal 1, results.size
      assert_equal "Chicago, IL, USA", results.first[:name]
    ensure
      class << WeatherService
        alias_method :fetch_cities_from_api, :original_fetch_cities
        remove_method :original_fetch_cities
      end
    end
  end

  test "moon_phase_details returns correct description, emoji, and illumination" do
    new_moon = WeatherService.moon_phase_details(0)
    assert_equal "New Moon", new_moon[:name]
    assert_equal "🌑", new_moon[:emoji]
    assert_equal 0, new_moon[:illumination]

    first_quarter = WeatherService.moon_phase_details(0.25)
    assert_equal "First Quarter", first_quarter[:name]
    assert_equal "🌓", first_quarter[:emoji]
    assert_equal 50, first_quarter[:illumination]

    full_moon = WeatherService.moon_phase_details(0.5)
    assert_equal "Full Moon", full_moon[:name]
    assert_equal "🌕", full_moon[:emoji]
    assert_equal 100, full_moon[:illumination]

    third_quarter = WeatherService.moon_phase_details(0.75)
    assert_equal "Third Quarter", third_quarter[:name]
    assert_equal "🌗", third_quarter[:emoji]
    assert_equal 50, third_quarter[:illumination]

    gibbous = WeatherService.moon_phase_details(0.4)
    assert_equal "Waxing Gibbous", gibbous[:name]
    assert_equal "🌔", gibbous[:emoji]
    assert_equal 80, gibbous[:illumination]
  end
end
