class Api::WeeklyInsightsController < ApplicationController
  before_action :api_require_login

  def create
    week_key = weekly_insight_week_key(current_user)
    cached = Rails.cache.read(week_key)


    if cached.present?
      render json: { id: week_key }, status: :ok
      return
    end

    reflection = Reflection::OpenaiService
    .new(daily_notes: fetch_weekly_notes(current_user))
    .call

    Rails.cache.write(
      week_key,
      reflection,
      expires_in: 8.days
    )

    render json: { id: week_key }, status: :created
  end

  def fragment
    week_key = params[:id]
    weekly_insight = Rails.cache.read(week_key)
    if weekly_insight.nil?
      render json: { error: "Not Found" }, status: :not_found
      return
    end
    render partial: "analysis/weekly_insight", locals: { weekly_insight: weekly_insight }, formats: [ :html ]
  end

  private

  def api_require_login
    return if current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def fetch_weekly_notes(user)
    base_date = Time.zone.today - 1.week
    start_date = base_date.beginning_of_week
    end_date = base_date.end_of_week

    user.daily_notes.where(date: start_date..end_date)
  end
end
