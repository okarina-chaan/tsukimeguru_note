# app/controllers/calendar_controller.rb
class CalendarController < ApplicationController
  before_action :require_login

  def show
    @year = params[:year]&.to_i || Date.today.year
    @month = params[:month]&.to_i || Date.today.month

    start_date = Date.new(@year, @month, 1)
    end_date = start_date.end_of_month

    moon_phases = MoonPhaseRepository.fetch_month(@year, @month)
    moon_phases_by_date = moon_phases.index_by(&:date)

    # 月の4大イベント日を取得（配列になる）
    monthly_events = MoonApiService.fetch_monthly_events_with_range(@year, @month)

    days = (start_date..end_date).map do |date|
      moon_phase = moon_phases_by_date[date]

      {
        date: date,
        moon_phase: moon_phase&.display_name,
        emoji: moon_phase&.display_emoji,
        angle: moon_phase&.angle,
        new_moon: monthly_events[:new_moon].include?(date),
        full_moon: monthly_events[:full_moon].include?(date),
        first_quarter: monthly_events[:first_quarter_moon].include?(date),
        last_quarter: monthly_events[:last_quarter_moon].include?(date),
        creatable_moon_note: moon_phase&.creatable_for_moon_note?
      }
    end

    first_wday = (start_date.wday - 1) % 7
    blank_days = Array.new(first_wday) { nil }
    all_days = blank_days + days

    while all_days.size % 7 != 0
      all_days << nil
    end

    @weeks = all_days.each_slice(7).to_a
  end
end
