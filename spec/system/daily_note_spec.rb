require "rails_helper"

RSpec.describe "Daily note機能", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe "Daily note作成" do
    it "正しく保存できる" do
      visit new_daily_note_path

      find("input[name='daily_note[condition_score]']", visible: false).set("5")
      find("input[name='daily_note[mood_score]']", visible: false).set("4")

      sleep 0.5
      puts page.html
      click_button "保存する"

      expect(page).to have_content("Daily noteを保存しました")
      expect(DailyNote.count).to eq(1)
    end

    it "バリデーションエラーで保存されない" do
      visit new_daily_note_path
      click_button "保存する"

      expect(page).to have_content("体調を入力してください")
      expect(page).to have_content("気分を入力してください")
      expect(DailyNote.count).to eq(0)
    end
  end

  describe "同じ日のDaily note作成制限" do
    let!(:today_note) do
      create(:daily_note,
             user: user,
             date: Date.today,
             condition_score: 4,
             mood_score: 3)
    end
    it "同じ日にちで2回目の作成をしようとすると編集画面にリダイレクトされる" do
      visit new_daily_note_path

      expect(page).to have_current_path(edit_daily_note_path(today_note))
      expect(page).to have_content("Daily Noteを編集する")
    end
  end

  let(:other_user) { create(:user) }

  describe "Daily note一覧" do
    let!(:one_note) do
      create(:daily_note,
             user: user,
             date: Date.yesterday,
             did_today: "朝早起きした。",
             try_tomorrow: "今夜も22時には寝る。")
    end

    let!(:other_note) do
      create(:daily_note,
             user: other_user,
             date: Date.today,
             did_today: "スマホを見すぎた。",
             try_tomorrow: "朝ストレッチをする。")
    end

    it "ユーザーが作成したDaily noteだけ表示される" do
      visit daily_notes_path

      expect(page).to have_selector("h1", text: "Daily Note一覧")
      expect(page).to have_content("朝早起きした。")
      expect(page).not_to have_content("スマホを見すぎた。")
    end
  end

  describe "Daily noteの編集", js: true do
    let!(:note) do
      create(
        :daily_note,
        user: user,
        condition_score: 3,
        mood_score: 2,
        did_today: "朝早起きした。",
        try_tomorrow: "今夜も22時には寝る。"
      )
    end

    it "編集画面で既存データがUIに反映されている" do
      visit edit_daily_note_path(note)

      expect(page).to have_field(
        "daily_note_did_today",
        with: "朝早起きした。"
      )

      expect(page).to have_css(
        '[data-group="health"] .active[data-value="3"]'
      )

      expect(page).to have_css(
        '[data-group="mood"] .active[data-value="2"]'
      )
    end
  end

  describe "Daily noteの削除" do
    let!(:note) { create(:daily_note, user: user) }

    it "削除できる" do
      visit daily_notes_path

      click_link "削除する"
      expect(page).to have_content("Daily noteを削除しました")
    end
  end
end
