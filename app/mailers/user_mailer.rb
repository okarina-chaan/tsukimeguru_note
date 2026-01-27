class UserMailer < ApplicationMailer
  def deletion_email(user, url)
    @user = user
    @url = url

    mail(
      to: @user.email,
      subject: "【月めぐるノート】アカウント削除確認メール"
    )
  end
end
