class EmailsController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(email_params)
      redirect_to settings_path, notice: "メールアドレスを登録しました"
    else
      flash.now[:alert] = "メールアドレスの登録に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def email_params
    params.require(:user).permit(:email)
  end
end
