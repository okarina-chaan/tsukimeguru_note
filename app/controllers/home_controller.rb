class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to dashboard_path
    else
      render :index
    end
  end

  def dashboard; end
end
