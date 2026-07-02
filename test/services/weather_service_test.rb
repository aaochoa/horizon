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
    assert_equal "help", unknown[:icon]
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
end
