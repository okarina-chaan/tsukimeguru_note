class UsersController < ApplicationController
  before_action :require_login, only: %i[ mypage send_email confirm_destroy destroy_account]

  def mypage
  end

  def send_email
  end

  def confirm_destroy
    @user = current_user

    if request.post?
      unless @user.email.present?
        redirect_to edit_email_path, alert: "削除連絡用のメールアドレスを登録してください"
        return
      end

      token = @user.signed_id(expires_in: 30.minutes, purpose: :destroy_account)
      delete_url = destroy_account_users_url(token: token)
      UserMailer.deletion_email(@user, delete_url).deliver_now

      redirect_to send_email_users_path
    else
      render :confirm_destroy
    end
  end

  def destroy_account
    @user = User.find_signed(params[:token], purpose: :destroy_account)

    unless @user
      redirect_to root_path, alert: "このリンクは無効か、有効期限が切れています"
      return
    end

    unless current_user == @user
      redirect_to root_path, alert: "このリンクはこのアカウントでは使えません"
      return
    end

    if request.delete?
      @user.destroy
      reset_session
      redirect_to page_path("destroyed")
    end
  end
end
