class WeatherController < ApplicationController
  allow_unauthenticated_access only: %i[ index search ]

  def index
    # Default to Chicago, IL if no coordinates are specified
    @latitude = params[:lat].presence || "41.8781"
    @longitude = params[:lon].presence || "-87.6298"
    @location_name = params[:name].presence || "Chicago, IL"

    @weather = WeatherService.get_weather(
      @latitude.to_f.round(4), 
      @longitude.to_f.round(4), 
      force_refresh: params[:refresh] == "true"
    )

    if authenticated?
      @favorites = Current.user.favorite_locations.order(:name)
      @is_favorited = @favorites.any? { |f| (f.latitude - @latitude.to_f).abs < 0.001 && (f.longitude - @longitude.to_f).abs < 0.001 }
    else
      @favorites = []
      @is_favorited = false
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def search
    query = params[:q]
    results = WeatherService.search_cities(query)
    render json: results
  end
end
