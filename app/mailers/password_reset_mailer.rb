class PasswordResetMailer < ApplicationMailer
  def password_reset_email(email, url)
    @email = email
    @reset_url = url

    mail(
      to: @email,
      subject: "【月めぐるノート】パスワードリセットのご案内"
    )
  end
end
