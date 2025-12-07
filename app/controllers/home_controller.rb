class HomeController < ApplicationController
  def index
    redirect_to dashboard_path if current_user.present?
  end

  def dashboard; end
end
