require "rails_helper"

RSpec.describe "Moon Note", type: :system do
  let(:user) { create(:user, :registered) }

  before { sign_in_as(user) }

  describe "moon note作成" do
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

  describe "moon note一覧" do
    context "moon noteが存在する場合" do
      let!(:moon_note) { create(:moon_note, user: user, date: Date.today - 1) }
      it "moon note一覧が表示される" do
        visit moon_notes_path
        expect(page).to have_content("今日は満月です。心が穏やかになります。")
      end
    end

    context "moon noteが存在しない場合" do
      it "moon noteが存在しないことが表示される" do
        visit moon_notes_path
        expect(page).to have_content("まだノートがありません")
      end
    end
  end

  describe "moon note編集" do
    let!(:moon_note) { create(:moon_note, user: user, date: Date.today - 1, content: "更新前だよ") }

    context "正常" do
      it "moon noteを正しく更新できる" do
        visit edit_moon_note_path(moon_note)

        fill_in "moon_note_content", with: "本文を更新するよ"
        click_button "更新する"

        expect(page).to have_current_path(moon_notes_path)
        expect(page).to have_content("更新しました")
      end
    end

    context "異常" do
      it "contentが空欄のときはエラーメッセージが出る" do
        visit edit_moon_note_path(moon_note)

        fill_in "moon_note_content", with: ""
        click_button "更新する"

        expect(page).to have_content("本文を入力してください")
      end
    end
  end

  describe "moon note削除", js: true do
    let!(:moon_note) { create(:moon_note, user: user, date: Date.today - 1) }

    it "moon noteを正しく削除できる" do
      visit moon_notes_path

      expect do
        accept_confirm "本当にこのMoon Noteを削除しますか？" do
          click_on :delete_button
        end
        expect(page).to have_content("削除しました")
      end.to change(MoonNote, :count).by(-1)

      expect(page).not_to have_content("今日は満月です。心が穏やかになります。")
    end
  end
end
