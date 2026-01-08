class DashboardController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @daily_note ||= current_user.daily_notes.build

    # Repository経由で取得
    moon_phase = MoonPhaseRepository.fetch_date(Date.today)

    # 今月のイベント日を取得
    today = Date.today
    monthly_events = MoonApiService.fetch_monthly_events_with_range(today.year, today.month)

    # 今日がどのイベントか判定
    event = nil
    event = :new_moon if monthly_events[:new_moon].include?(today)
    event = :full_moon if monthly_events[:full_moon].include?(today)
    event = :first_quarter_moon if monthly_events[:first_quarter_moon].include?(today)
    event = :last_quarter_moon if monthly_events[:last_quarter_moon].include?(today)

    @dashboard_data = {
      today: Date.today.strftime("%Y年 %m月 %d日 (%a)"),
      moonPhase: moon_phase&.display_name,
      moonPhaseEmoji: moon_phase&.display_emoji,
      event: event,
      eventName: MoonApiService.phase_name_for_event(event),
      canCreateMoonNote: moon_phase&.creatable_for_moon_note?
    }
  end
end
