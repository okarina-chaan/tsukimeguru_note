class AccountNamesController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params.merge(account_registered: true))
      redirect_to dashboard_path, notice: "アカウント名が登録されました"
    else
      flash.now[:alert] = "アカウント名の登録に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end

  def require_login
    redirect_to root_path, alert: "ログインしてください" unless current_user
  end
end
