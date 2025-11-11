class AccountNamesController < ApplicationController
  before_action :require_login
  before_action :redirect_if_registered, only: [:edit, :update]

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


  def redirect_if_registered
    if current_user.account_registered?
      redirect_to dashboard_path, notice: "既にアカウント名が登録されています"
    end
  end
end
