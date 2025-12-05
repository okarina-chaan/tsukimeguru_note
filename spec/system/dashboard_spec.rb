require 'rails_helper'

RSpec.describe 'Dashboard', type: :system do
  let(:user) { create(:user) }
  before do
    sign_in_as(user)
  end
  describe 'dashboardにアクセス' do
    it '正常に表示されること' do
      visit dashboard_path
      expect(page).to have_content '今日はどんな記録を残しますか？'
    end

    it 'Daily Note作成ページに遷移できること' do
      visit dashboard_path
      click_on 'Daily Noteを書く'

      expect(page).to have_current_path new_daily_note_path
    end

    
    it '特定の月相のときにMoon Note作成ページに遷移できること' do
        allow(MoonApiService).to receive(:fetch).and_return(
          event: :full_moon,
          moon_phase_name: "満月",
          moon_phase_emoji: "🌕",
          moon_age: 14.3,
          date: Date.today
        )

      visit dashboard_path
      puts page.html
      find('[data-testid="moon-note-card"]').click

      expect(page).to have_current_path new_moon_note_path
    end

    before do
      allow(MoonApiService).to receive(:fetch).and_return(
        event: nil,
        moon_phase_name: "その他",
        moon_phase_emoji: "",
        moon_age: 12.0,
        date: Date.today
      )
    end

    it '特定の月相でないときにMoon Note作成ページに遷移できないこと' do
      visit dashboard_path
      expect(page).not_to have_link 'Moon Noteを書く'
      expect(page).to have_content '対象日ではありません'
    end
  end
end

