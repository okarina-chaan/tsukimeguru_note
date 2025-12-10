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

    it "Daily noteの編集ができる" do
      visit daily_notes_path

      click_link "編集する", href: edit_daily_note_path(one_note)
      expect(page).to have_content("Daily noteを編集する")
      click_button "更新する"
      expect(page).to have_content("Daily noteを更新しました")
    end

    it "Daily noteの削除ができる" do
      visit daily_notes_path
      click_link "削除する", href: daily_note_path(one_note)
      expect(page).to have_content("Daily noteを削除しました")
    end
  end
end
