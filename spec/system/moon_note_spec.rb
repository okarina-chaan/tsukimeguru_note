require "rails_helper"

RSpec.describe "Moon Note作成フロー", type: :system do
  let(:user) { create(:user, :registered) }

  before { sign_in_as(user) }

  context "今日は満月" do
    before do
      allow(MoonApiService).to receive(:fetch).and_return(
        event: :full_moon,
        moon_phase_name: "満月",
        moon_phase_emoji: "🌕",
        moon_age: 14.3,
        date: Date.today
      )
    end

    it "moon note作成画面に遷移できる" do
      visit new_moon_note_path
      expect(page).to have_content("今日は満月です。Moon Noteを作成しましょう！")
      expect(page).to have_button("保存する")
    end

    it "moon noteを正しく保存できる" do
      visit new_moon_note_path
      fill_in "moon_note_content", with: "早起きが習慣になってきた。"
      click_button "保存する"

      expect(page).to have_content("Moon Noteを保存しました")
      expect(MoonNote.count).to eq(1)
      expect(MoonNote.last.moon_phase).to eq("full_moon")
    end
  end

  context "今日はどの月相にもあたらない" do
    before do
      allow(MoonApiService).to receive(:fetch).and_return(
        event: nil,
        moon_phase_name: "その他",
        moon_phase_emoji: "",
        moon_age: 12.0,
        date: Date.today
      )
    end

    it "moon note作成画面に遷移できずダッシュボードにリダイレクトされる" do
      visit new_moon_note_path
      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_content("今日のMoon Noteはありません。")
    end
  end
end
