class DashboardController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @daily_note ||= current_user.daily_notes.build

    data = MoonApiService.fetch(Date.today)
    @dashboard_data = {
      today: Date.today.strftime("%Y年 %m月 %d日 (%a)"),
      moonPhase: data[:moon_phase_name],
      moonPhaseEmoji: data[:moon_phase_emoji],
      event: data[:event],
      eventName: data[:event_name],
      canCreateMoonNote: MoonApiService.creatable_moon_note?(data[:angle])
    }
  end
end
