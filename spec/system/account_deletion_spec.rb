require 'rails_helper'

RSpec.describe 'アカウント削除', type: :system do
  let!(:user) { create(:user, email: "test@example.com") }

  before do
    sign_in_as(user)
  end

  describe "正常系: アカウント削除フロー" do
    it "退会申請を行い、メールを受信し、最終的にアカウントを削除できる" do
      visit confirm_destroy_users_path
      expect(page).to have_content("本当に退会しますか？")

      click_button "退会する"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include(user.email)
      expect(mail.subject).to include("アカウント削除")

      expect(page).to have_current_path(send_email_users_path)

      body = mail.html_part.decoded
      match = body.match(/href="([^"]*destroy_account[^"]*)"/)

      if match.nil? && mail.text_part
        body = mail.text_part.decoded
        match = body.match(/(http.*?destroy_account.*?)\s/)
      end

      deletion_url = match[1]
      visit deletion_url

      expect(page).to have_content("退会の最終確認")

      expect {
        click_button "退会する"
      }.to change { User.count }.by(-1)

      expect(page).to have_current_path(page_path("destroyed"))
    end
  end

  describe "準正常系: メールアドレス未登録" do
    let(:user_no_email) { create(:user, email: nil) }

    before do
      sign_in_as(user_no_email)
    end

    it "メール登録ページへ誘導される" do
      visit confirm_destroy_users_path

      click_button "退会する"

      expect(page).to have_current_path(edit_email_path)
      expect(page).to have_content("削除連絡用のメールアドレスを登録してください")
    end
  end
end
