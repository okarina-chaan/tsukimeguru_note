require 'rails_helper'

RSpec.describe "Home", type: :system do
  describe "フッター" do
    it "利用規約ページにアクセスできる" do
      visit root_path
      click_link "利用規約"
      expect(page).to have_content "月めぐるノート 利用規約"
    end

    it "プライバシーポリシーページにアクセスできる" do
      visit root_path
      click_link "プライバシーポリシー"
      expect(page).to have_content "プライバシーポリシー"
    end
  end
end 