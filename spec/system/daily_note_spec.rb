require "rails_helper"

RSpec.describe "Daily note機能", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe "Daily note作成" do
    context "正常系" do
      it "今日の日付でDaily noteが正しく保存できる" do
        visit new_daily_note_path
        fill_in "daily_note_date",	with: Time.zone.today
        find('[aria-label="体調スコア 5"]').click
        find('[aria-label="気分スコア 4"]').click
        click_button "保存する"

        expect(page).to have_content("Daily noteを保存しました")
        expect(DailyNote.count).to eq(1)
      end

      it "過去の日付でDaily noteが正しく保存できる" do
        visit new_daily_note_path
        fill_in "daily_note_date",	with: (Time.zone.today - 3.days)
        find('[aria-label="体調スコア 3"]').click
        find('[aria-label="気分スコア 2"]').click
        click_button "保存する"

        expect(page).to have_content("Daily noteを保存しました")
        expect(DailyNote.count).to eq(1)
      end
    end

    context "異常系" do
      it "必須項目が入力されていないときは保存されない" do
        visit new_daily_note_path
        click_button "保存する"

        expect(page).to have_content("体調を入力してください")
        expect(page).to have_content("気分を入力してください")
        expect(DailyNote.count).to eq(0)
      end

      it "同じ日のDaily noteは2つ保存できない" do
        create(:daily_note, user: user, date: Time.zone.today)

        visit new_daily_note_path
        fill_in "daily_note_date",	with: Time.zone.today
        find('[aria-label="体調スコア 4"]').click
        find('[aria-label="気分スコア 3"]').click
        click_button "保存する"

        expect(page).to have_content("（#{Time.zone.today.strftime("%Y年%m月%d日")}）は既に登録されています")
        expect(DailyNote.count).to eq(1)
      end

      it "未来の日付のDaily noteは保存できない" do
        visit new_daily_note_path
        fill_in "daily_note_date",	with: (Time.zone.today + 3.days)
        find('[aria-label="体調スコア 4"]').click
        find('[aria-label="気分スコア 3"]').click
        click_button "保存する"

        expect(page).to have_content("日付は今日より過去の日付にしてください")
        expect(DailyNote.count).to eq(0)
      end
    end
  end

  let(:other_user) { create(:user) }

  describe "Daily note一覧" do
    let!(:one_note) do
      create(:daily_note,
             user:         user,
             date:         Time.zone.yesterday,
             did_today:    "朝早起きした。",
             try_tomorrow: "今夜も22時には寝る。")
    end

    let!(:other_note) do
      create(:daily_note,
             user:          other_user,
             date:          Time.zone.today,
             did_today:     "スマホを見すぎた。",
             try_tomorrow:  "朝ストレッチをする。")
    end

    it "ユーザーが作成したDaily noteだけ表示される" do
      visit daily_notes_path

      expect(page).to have_selector("h1", text: "Daily Note一覧")
      expect(page).to have_content("#{Time.zone.yesterday.strftime("%Y年%m月%d日")}")
    end

    it "ページネーションが正しく機能する" do
      # 既に let! で Time.zone.yesterday のノートが作られているため、ループで同じ日付を再作成しないようにして作成する
      20.times do |i|
        create(:daily_note, user: user, date: Time.zone.today - (i + 2))
      end

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
    let!(:note) { create(:daily_note, user: user, date: Time.zone.today, condition_score: 3, mood_score: 4) }

    it "削除できる" do
      visit daily_notes_path

      expect {
        page.accept_confirm("本当にこの日記を削除しますか？") do
          click_on "削除する"
        end
        expect(page).to have_content("Daily noteを削除しました")
      }.to change { DailyNote.count }.by(-1)
    end
  end
end
