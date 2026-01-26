class UsersController < ApplicationController
  before_action :require_login, only: %i[ mypage send_email confirm_destroy]

  def mypage
  end

  def send_email
  end

  def confirm_destroy
    @user = current_user

    # POSTされたときの挙動
    if request.post?
      # メールアドレスがない場合はエラー
      unless @user.email.present?
        redirect_to edit_email_path, alert: "削除連絡用のメールアドレスを登録してください"
        return
      end

      # トークンの生成をする
      token = @user.signed_id(expires_in: 30.minutes, purpose: :destroy_account)
      # 削除リンクURLを作成する
      delete_url = destroy_account_url(token: token)
      # メーラーに引数として渡し、メールを送信する
      UserMailer.deletion_email(@user, delete_url).deliver_now

      redirect_to send_email_path
    # GETのときはビューの表示をする(書いたほうがわかりやすいから書く)
    else
      render :confirm_destroy
    end
  end

  def destroy_account
    @user = User.find_signed(params[:token], purpose: :destroy_account)

    # トークンの検証ができなかったときはマイページへリダイレクトさせる
    unless @user
      redirect_to root_path, alert: "このリンクは無効か、有効期限が切れています"
      return
    end

    if request.delete?
      @user.destroy
      reset_session
      redirect_to page_path("destroyed")
    end
  end
end
