class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(email: registration_params[:email])
    @authentication = @user.authentications.build(
      provider: 'email',
      uid: registration_params[:email],
      password: registration_params[:password],
      password_confirmation: registration_params[:password_confirmation]
    )

    if @user.save
      session[:user_id] = @user.id
      redirect_to edit_account_name_path, notice: "アカウントを作成しました"
    else
      flash.now[:alert] = "登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
