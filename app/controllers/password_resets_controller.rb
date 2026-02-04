class PasswordResetsController < ApplicationController
  rate_limit to:        10,
             within:    1.hour,
             only:      [ :create ],
             by:        -> { request.remote_ip || "unknown" }

  def new
    @email = params[:email]
  end

  def create
    if params[:email].blank?
      redirect_to root_path, alert: t(".email_blank")
      return
    end

    @email = params[:email]
    @user = User.find_by(email: params[:email])

    # ユーザーが存在しない場合でも、セキュリティ上の理由から同じメッセージを表示する
    unless @user
      redirect_to sent_password_resets_path, notice: t(".email_sent")
      return
    end

    token = @user.signed_id(expires_in: 30.minutes, purpose: :password_reset)
    reset_url = edit_password_resets_url(token: token)
    PasswordResetMailer.password_reset_email(@email, reset_url).deliver_now

    redirect_to sent_password_resets_path, notice: t(".email_sent_with_period")
  end

  def sent
  end

  def edit
    @user = User.find_signed(params[:token], purpose: :password_reset)

    unless @user
      redirect_to root_path, alert: t(".invalid_or_expired_link")
      nil
    end
  end

  def update
    @user = User.find_signed(params[:token], purpose: :password_reset)

    unless @user
      redirect_to root_path, alert: t(".invalid_or_expired_link")
      return
    end

    if params[:password].blank?
      flash.now[:alert] = t(".password_blank")
      render :edit, status: :unprocessable_entity
      return
    end

    if params[:password] != params[:password_confirmation]
      flash.now[:alert] = t(".password_mismatch")
      render :edit, status: :unprocessable_entity
      return
    end

    # email認証を取得してパスワードリセットの分岐を作る
    # 存在しない場合はエラーメッセージを表示してrootへリダイレクト
    email_auth = @user.email_authentication
    unless email_auth
      redirect_to root_path, alert: t(".email_auth_not_set")
      return
    end

    # パスワードを更新
    if email_auth.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to new_session_path, notice: "パスワードをリセットしました。ログインしてください"
    else
      flash.now[:alert] = email_auth.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end
end
