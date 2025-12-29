class Api::WeeklyInsightsController < ApplicationController
  before_action :api_require_login
  # X-CSRF-Tokenを　Reactで実装したら外す
  skip_before_action :verify_authenticity_token

  def create

    week_key = weekly_insight_week_key(current_user, at: Time.zone.now)
    weekly_insight = Rails.cache.fetch(week_key, expires_in: 8.days) {
      reflection = Api::WeeklyInsightReflectionService.new(current_user).call
      html = render_to_string(partial: "api/weekly_insights/weekly_insight", locals: { weekly_insight: reflection })
      {id: week_key, html: html}
    }

    render json: { id: weekly_insight[:id]}
    
  end

  def fragment
    week_key = params[:id]
    weekly_insight = Rails.cache.read(week_key)
    if weekly_insight.nil?
      render json: { error: "Not Found" }, status: :not_found
      return
    end
    render partial: "api/weekly_insights/weekly_insight", locals: { weekly_insight: weekly_insight }, formats: [:html]
  end

  private

  def api_require_login
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
