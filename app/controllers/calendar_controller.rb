class CalendarController < ApplicationController
  before_action :require_login

  def show
    @year = params[:year]&.to_i || Date.today.year
    @month = params[:month]&.to_i || Date.today.month

    start_date = Date.new(@year, @month, 1)
    end_date = start_date.end_of_month

    days = (start_date..end_date).map do |date|
      moon_data = MoonApiService.fetch(date)
      Rails.logger.info "PHASE: #{moon_data&.dig(:moon_phase_name)}"
      angle = moon_data&.dig(:moon_phase_angle).to_f

      {
        date: date,
        moon_phase:  moon_data&.dig(:moon_phase_name),
        emoji:       moon_data&.dig(:moon_phase_emoji),
        angle:       angle,
        new_moon: moon_data&.dig(:event) == :new_moon,
        full_moon: moon_data&.dig(:event) == :full_moon,
        first_quarter: moon_data&.dig(:event) == :first_quarter_moon,
        last_quarter: moon_data&.dig(:event) == :last_quarter_moon
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
