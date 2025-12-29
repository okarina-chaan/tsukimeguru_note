class Api::WeeklyInsightsController < ApplicationController
  before_action :api_require_login
  # X-CSRF-Tokenを　Reactで実装したら外す
  skip_before_action :verify_authenticity_token

  def create
    week_key = weekly_insight_week_key(current_user)
    cached_weekly_insight = Rails.cache.read(week_key)
    if cached_weekly_insight.present?
      render json: {id: week_key}, status: :ok
      return
    else
      weekly_insight = Rails.cache.fetch(week_key, expires_in: 8.days) do
        reflection = Reflection::MockService.new(daily_notes: fetch_weekly_notes(current_user)).call

        html = render_to_string(
          partial: "analysis/weekly_insight",
          locals: { weekly_insight: reflection },
          layout: false
        )
        { id: week_key, html: html }
      end
      render json: {id: week_key}, status: :created
    end
  end


  def fragment
    week_key = params[:id]
    weekly_insight = Rails.cache.read(week_key)
    if weekly_insight.nil?
      render json: { error: "Not Found" }, status: :not_found
      return
    end
    render partial: "analysis/weekly_insight", locals: { weekly_insight: weekly_insight }, formats: [:html]
  end

  private

  def api_require_login
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def fetch_weekly_notes(user)
    base_date = Time.zone.today - 1.week
    start_date = base_date.beginning_of_week
    end_date = base_date.end_of_week

    user.daily_notes.where(date: start_date..end_date)
  end
end
