class UnitsController < ApplicationController
  allow_unauthenticated_access only: :update

  def update
    unit = params[:unit_system]
    if %w[imperial metric].include?(unit)
      if authenticated?
        Current.user.update!(unit_system: unit)
      else
        session[:unit_system] = unit
      end
    end

    redirect_back_or_to root_path
  end
end
