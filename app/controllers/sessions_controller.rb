class SessionsController < ApplicationController
  def new
    # ログインフォーム表示
  end

  def create
    # email/passwordでのログイン
    authentication = Authentication.find_by(provider: "email", uid: params[:email])

    if authentication&.authenticate(params[:password])
      session[:user_id] = authentication.user_id
      redirect_to dashboard_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました"
  end
end
