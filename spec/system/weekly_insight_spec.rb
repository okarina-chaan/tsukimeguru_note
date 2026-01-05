require 'rails_helper'

RSpec.describe '週次振り返り機能', type: :system, js: true do
  let(:user) { create(:user) }
  let(:start_date) { 1.week.ago.beginning_of_week }

  before do
    sign_in_as(user)
  end

  describe '振り返り生成フロー' do
    context '日記データが存在する場合' do
      before do
        3.times do |i|
          create(:daily_note,
            user: user,
            date: start_date + i.days,
            condition_score: 3,
            mood_score: 4,
            good_things: '良いことがありました'
          )
        end
        Rails.cache.clear
      end

      it '振り返りボタンをクリックしてローディングが表示される' do
        visit analysis_path

        expect(page).to have_text('先週の振り返り', wait: 10)
        expect(page).to have_button('先週を振り返る', wait: 10)

        click_button '先週を振り返る'

        expect(page).to have_css('[data-testid="loader"]', wait: 10)
      end
    end

    context '日記データが不足している場合' do
      it '振り返り機能が利用できないことが分かる' do
        visit analysis_path

        expect(page).to have_text('AIによる振り返りは、週に1回生成されます。')
      end
    end
  end

  describe 'キャッシュされた振り返りの表示' do
    before do
      user.update!(weekly_insight_generated_at: 1.week.ago)
      week_key = "weekly_insight_user_#{user.id}_week_#{start_date.to_date}"
      Rails.cache.write(week_key, {
        'question' => "テスト質問",
        'summary' => "テスト要約"
      })
    end

    it 'キャッシュされた振り返り結果が表示される' do
      visit analysis_path

      expect(page).to have_text('ちょっと立ち止まってみる')
    end
  end

  describe 'ボタン状態の制御' do
    it '既に振り返りを生成済みの場合は制限メッセージが表示される' do
      user.update!(weekly_insight_generated_at: Time.current)

      visit analysis_path

      expect(page).to have_text('週に1回だけ振り返りを更新できます', wait: 10)
    end

    it '新しい週になったらボタンが有効になる' do
      user.update!(weekly_insight_generated_at: 2.weeks.ago)

      visit analysis_path

      expect(page).to have_button('先週を振り返る', wait: 10)
      expect(page).not_to have_text('週に1回だけ振り返りを更新できます')
    end
  end
end
