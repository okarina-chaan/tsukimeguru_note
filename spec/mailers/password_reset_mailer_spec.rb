require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  describe "パスワードリセットメール" do
    let(:email) { "test@email.com" }
    let(:url) { "http://example.com/password_resets/reset/token123" }
    let(:mail) { PasswordResetMailer.password_reset_email(email, url) }

    it "正常にメールが送信されること" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "メールの宛先が正しく設定されること" do
      expect(mail.to).to eq([ email ])
    end

    it "メールの件名が正しく設定されること" do
      expect(mail.subject).to eq("【月めぐるノート】パスワードリセットのご案内")
    end

    it "メールの本文が正しく設定されること" do
      html_part = mail.body.parts.find { |part| part.content_type.match(/html/) }
      expect(html_part.body.encoded).to include("<p>以下のURLをクリックしてパスワードをリセットしてください</p>")
      text_part = mail.body.parts.find { |part| part.content_type.match(/text/) }
      expect(text_part.body.encoded).to include("以下のURLをクリックしてパスワードをリセットしてください")
    end

    it "メールの本文にパスワードリセットのURLが含まれること" do
      html_part = mail.body.parts.find { |part| part.content_type.match(/html/) }
      expect(html_part.body.encoded).to include(url)
      text_part = mail.body.parts.find { |part| part.content_type.match(/text/) }
      expect(text_part.body.encoded).to include(url)
    end
  end
end
