require "rails_helper"
require "base64"

RSpec.describe UserMailer, type: :mailer do
  describe "ユーザー削除確認メール" do
    let(:user) { create(:user, email: "test@email.com", name: "test") }
    let(:url) { "http://example.com/users/destroy_account/token123" }
    let(:mail) { UserMailer.deletion_email(user, url) }

    it "正常にメールが送信されること" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "メールの宛先が正しく設定されること" do
      expect(mail.to).to eq([ user.email ])
    end

    it "メールの件名が正しく設定されること" do
      expect(mail.subject).to eq("【月めぐるノート】アカウント削除確認メール")
    end

    it "メールの本文が正しく設定されること" do
      html_part = mail.body.parts.find { |part| part.content_type.match(/html/) }
      expect(html_part.body.encoded).to match(/<p>月めぐるノートを使ってくださってありがとうございました<\/p>/)
      text_part = mail.body.parts.find { |part| part.content_type.match(/text/) }
      expect(text_part.body.encoded).to match(/月めぐるノートを使ってくださってありがとうございました/)
    end

    it "メールの本文にユーザー名が含まれること" do
      html_part = mail.body.parts.find { |part| part.content_type.match(/html/) }
      expect(html_part.body.encoded).to include("<p>test様</p>")
      text_part = mail.body.parts.find { |part| part.content_type.match(/text/) }
      expect(text_part.body.encoded).to include("test様")
    end

    it "メールの本文に退会手続きのURLが含まれること" do
      html_part = mail.body.parts.find { |part| part.content_type.match(/html/) }
      expect(html_part.body.encoded).to include(url)
      text_part = mail.body.parts.find { |part| part.content_type.match(/text/) }
      expect(text_part.body.encoded).to include(url)
    end

    it "メールの本文に有効期限が含まれること" do
      html_part = mail.body.parts.find { |part| part.content_type.match(/html/) }
      expect(html_part.body.encoded).to include("30分間有効")
      text_part = mail.body.parts.find { |part| part.content_type.match(/text/) }
      expect(text_part.body.encoded).to include("30分間有効")
    end
  end
end
