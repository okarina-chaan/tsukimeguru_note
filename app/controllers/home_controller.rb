class HomeController < ApplicationController
  def index
    @moon = MoonApiService.fetch(Date.today)
    redirect_to dashboard_path if current_user.present?
  end

  def dashboard; end
end
