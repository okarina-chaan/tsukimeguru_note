class HomeController < ApplicationController
  def index
    Rails.logger.info("Moon value: #{@moon.inspect}")
    @moon = MoonApiService.fetch(Date.today)
    redirect_to dashboard_path if current_user
  end

  def dashboard; end
end
