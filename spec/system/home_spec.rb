require 'rails_helper'

RSpec.describe "ホーム画面", js: true, type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    page.driver.browser.manage.delete_all_cookies
  end

  describe "表示内容の確認" do
    it "ホーム画面に月相が表示されている" do
      visit root_path

      expect(page).to have_css(".moon-phase")
    end

    it "通信エラーの時にはエラーメッセージを出している" do
      allow(MoonApiService).to receive(:fetch).and_return(nil)

      visit root_path
      expect(page).to have_content("月相データを取得できませんでした")
    end
  end
end
