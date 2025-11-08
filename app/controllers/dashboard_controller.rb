class DashboardController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @daily_note = DailyNote.new
    # @moon_phase = MoonPhaseService.current_phase
  end
end
