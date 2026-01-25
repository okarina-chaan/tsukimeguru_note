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

      # TODO:トークンの生成をする
      # TODO:メールを送る処理をかく
      
      redirect_to send_email_path
    end
  end

  def destroy
    # トークンが無効の場合は削除確認画面へ移動させる
    
    reset_session
    redirect_to page_path("destroyed"), notice: "アカウント削除が完了しました。"
  end
end
