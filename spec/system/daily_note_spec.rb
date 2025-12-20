require "rails_helper"

RSpec.describe "Daily note機能", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe "Daily note作成" do
    it "正しく保存できる" do
      visit new_daily_note_path

      find('[aria-label="体調スコア 5"]').click
      find('[aria-label="気分スコア 4"]').click
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
      expect(page).to have_content("#{Date.yesterday.strftime("%Y年%m月%d日")}")
    end

    it "ページネーションが正しく機能する" do
      create_list(:daily_note, 25, user: user)

      visit daily_notes_path

      
      expect(page).to have_selector("h1", text: "Daily Note一覧")
      click_on '2', match: :first

      expect(page).to have_current_path(daily_notes_path(page: 2))
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

      page.dismiss_confirm("本当にこの日記を削除しますか？") do
        click_on "削除する"
      end
    end
  end
end
