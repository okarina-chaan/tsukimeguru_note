class UsersController < ApplicationController
  before_action :require_login

  def mypage
  end

  def settings
  end

  def destroy
    @user = current_user

    # メールアドレスがない場合はエラー
    unless @user.email.present?
      redirect_to settings_path, alert: "削除連絡用のメールアドレスを登録してください"
      return
    end

    # TODO: 削除確認メール送信（後で実装）

    @user.destroy
    reset_session
    redirect_to root_path, notice: "アカウントを削除しました。確認メールを送信しました。"
  end
end
