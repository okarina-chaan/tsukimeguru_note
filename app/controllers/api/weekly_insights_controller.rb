class Api::WeeklyInsightsController < ApplicationController
  before_action :api_require_login
  # X-CSRF-Tokenを　Reactで実装したら外す
  skip_before_action :verify_authenticity_token

  def create
    # 仮実装（まずはReactと繋がるか確認）
    render json: { id: 1 }, status: :created
  end

  private

  def api_require_login
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
