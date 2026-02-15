class LineMessageSettingsController < ApplicationController
  before_action :require_login

  def edit
    @line_message_setting = current_user.line_message_setting || current_user.build_line_message_setting
  end

  def update
    @line_message_setting = current_user.line_message_setting || current_user.build_line_message_setting

    if @line_message_setting.update(line_message_setting_params)
      redirect_to mypage_path, notice: "LINE通知の設定を保存しました"
    else
      flash.now[:alert] = "LINE通知を設定できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def line_message_setting_params
    params.require(:line_message_setting).permit(:new_moon, :first_quarter_moon, :full_moon, :last_quarter_moon)
  end
end
