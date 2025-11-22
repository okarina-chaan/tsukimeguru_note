class AnalysisController < ApplicationController
  before_action :require_login

  def show
    range = Date.today.beginning_of_month..Date.today.end_of_month

    daily_notes = current_user.daily_notes.where(date: range).order(:date)

    @dates       = daily_notes.map(&:date)
    @moods       = daily_notes.map(&:mood_score)
    @conditions  = daily_notes.map(&:condition_score)

    @moon_events = daily_notes.map.with_index do |note, idx|
      next unless note.moon_phase_name.in?(%w[full_moon new_moon])

      {
        date: note.date,
        type: note.moon_phase_name,
        emoji: note.moon_phase_emoji,
        index: idx
      }
    end.compact
  end
end
