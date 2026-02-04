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
      redirect_to root_path, alert: "メールアドレスを入力してください"
      return
    end

    @email = params[:email]
    @user = User.find_by(email: params[:email])

    # ユーザーが存在しない場合でも、セキュリティ上の理由から同じメッセージを表示する
    unless @user
      redirect_to sent_password_resets_path, notice: "メールを送信しました"
      return
    end

    token = @user.signed_id(expires_in: 30.minutes, purpose: :password_reset)
    reset_url = edit_password_resets_url(token: token)
    PasswordResetMailer.password_reset_email(@email, reset_url).deliver_now

    redirect_to sent_password_resets_path, notice: "メールを送信しました。"
  end

  def sent
  end

  def edit
    @user = User.find_signed(params[:token], purpose: :password_reset)

    # rubocop:disable Rails/I18nLocaleTexts
    unless @user
      redirect_to root_path, alert: "このリンクは無効か、有効期限が切れています"
      nil
    end
    # rubocop:enable Rails/I18nLocaleTexts
  end

  def update
    @user = User.find_signed(params[:token], purpose: :password_reset)

    unless @user
      redirect_to root_path, alert: "このリンクは無効か、有効期限が切れています"
      return
    end

    if params[:password].blank?
      flash.now[:alert] = "パスワードを入力してください"
      render :edit, status: :unprocessable_entity
      return
    end

    if params[:password] != params[:password_confirmation]
      flash.now[:alert] = "パスワードが一致しません"
      render :edit, status: :unprocessable_entity
      return
    end
    email_auth = @user.email_authentication

    if email_auth
      email_auth.update(
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      )
      redirect_to new_session_path, notice: "パスワードをリセットしました。ログインしてください"
    else
      redirect_to root_path, alert: "メール認証が設定されていません"
    end
  end
end
