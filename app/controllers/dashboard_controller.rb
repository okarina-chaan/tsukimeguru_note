class DashboardController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @daily_note ||= current_user.daily_notes.build
    @moon_data = MoonApiService.fetch(Date.today)
  end
end
