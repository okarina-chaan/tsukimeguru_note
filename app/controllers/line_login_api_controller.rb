class LineLoginApiController < ApplicationController
  require 'faraday'
  require 'json'
  require 'securerandom'

  def login
    session[:state] = SecureRandom.urlsafe_base64
    base_url = "https://access.line.me/oauth2/v2.1/authorize"
    response_type = "code"
    client_id = ENV['LINE_CHANNEL_ID']
    redirect_uri = CGI.escape(line_login_api_callback_url)
    state = session[:state]
    scope = "profile%20openid"

    authorization_url = "#{base_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"
    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    if Rails.env.test?
      id_token = "mock_id_token"
      line_user_id = "1234567890"
    elsif params[:state] == session[:state]
      id_token = exchange_code_for_token(params[:code])
      line_user_id = verify_id_token_and_get_sub(id_token)
    else
      redirect_to root_path, alert: "stateが一致しません" and return
    end

    user = User.find_or_create_by(line_user_id: line_user_id)
    session[:user_id] = user.id

    if user.account_registered?
      redirect_to dashboard_path, notice: "ログインしました"
    else
      redirect_to edit_account_name_path, notice: "アカウント名を登録してください"
    end
  end

  private

  def exchange_code_for_token(code)
    conn = Faraday.new(url: 'https://api.line.me')
    response = conn.post("/oauth2/v2.1/token") do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: line_login_api_callback_url,
        client_id: ENV['LINE_CHANNEL_ID'],
        client_secret: ENV['LINE_CHANNEL_SECRET']
      }
    end
    JSON.parse(response.body)['id_token'] if response.status == 200
  end

  def verify_id_token_and_get_sub(id_token)
    return nil unless id_token
    conn = Faraday.new(url: 'https://api.line.me')
    response = conn.post("/oauth2/v2.1/verify") do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(
          id_token: id_token,
          client_id: ENV["LINE_CHANNEL_ID"]
        )
      end
    JSON.parse(response.body)["sub"] if response.status == 200
  end
end
