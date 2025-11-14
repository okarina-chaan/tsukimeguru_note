require 'rails_helper'

RSpec.describe "ホーム画面", js: true, type: :system do
  describe "表示内容の確認" do
    it "ホーム画面に月相が表示されている" do
      visit root_path
      page.save_screenshot 'home_moon.png'
      expect(page).to have_css(".moon-phase")
    end
  end
end
