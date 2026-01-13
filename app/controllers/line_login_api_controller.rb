class LineLoginApiController < ApplicationController
  def login
    session[:state] = SecureRandom.urlsafe_base64
    authorization_url = ::LineAuth::AuthorizationService.new(
      state: session[:state],
      redirect_uri: line_login_api_callback_url
    ).authorization_url

    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    if params[:state] != session[:state]
      redirect_to root_path, alert: "不正なアクセスです"
      return
    end

    session.delete(:state)

    id_token = ::LineAuth::TokenService.new.exchange_code_for_token(
      code: params[:code],
      redirect_uri: line_login_api_callback_url
    )

    line_user_id = ::LineAuth::IdTokenVerifier.new.verify_and_get_user_id(id_token)

    # authenticationsテーブルから検索
    authentication = Authentication.find_by(provider: 'line', uid: line_user_id)

    if authentication
      user = authentication.user
    else
      # 新規ユーザー作成
      user = User.create!(line_user_id: line_user_id)
      user.authentications.create!(provider: 'line', uid: line_user_id)
    end

    session[:user_id] = user.id

    if user.account_registered?
      redirect_to dashboard_path, notice: "ログインしました"
    else
      redirect_to edit_account_name_path, notice: "アカウント名を登録してください"
    end
  rescue ::LineAuth::AuthenticationError
    redirect_to root_path, alert: "認証に失敗しました"
  end

  private

  def valid_state?(state)
    state.present? && session[:state].present? && state == session[:state]
  end
end
