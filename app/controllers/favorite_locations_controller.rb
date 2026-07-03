class FavoriteLocationsController < ApplicationController
  # Require authentication for all actions in this controller
  # (already set by default in application_controller)

  def create
    @favorite = Current.user.favorite_locations.new(favorite_params)

    if @favorite.save
      flash[:notice] = "#{@favorite.name} added to favorites."
    else
      flash[:alert] = @favorite.errors.full_messages.to_sentence
    end

    redirect_to root_path(lat: @favorite.latitude, lon: @favorite.longitude, name: @favorite.name)
  end

  def destroy
    @favorite = Current.user.favorite_locations.find(params[:id])
    name = @favorite.name
    @favorite.destroy

    flash[:notice] = "#{name} removed from favorites."
    redirect_to root_path(lat: params[:lat], lon: params[:lon], name: params[:name])
  end

  private

  def favorite_params
    params.require(:favorite_location).permit(:name, :latitude, :longitude)
  end
end
