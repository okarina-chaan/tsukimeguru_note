class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :require_login

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    redirect_to root_path, alert: "ログインしてください" unless current_user
  end

  def weekly_insight_week_key(user, at: Time.zone.today - 1.week)
    week_start = at.beginning_of_week.to_date.to_s
    "weekly_insight_user_#{user.id}_week_#{week_start}"
  end
end
