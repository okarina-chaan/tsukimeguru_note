require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validation' do
    example 'line_user_idは必須' do
      user = User.new(line_user_id: '')
      expect(user).to be_invalid

      user.line_user_id = '1'
      expect(user).to be_valid
    end
    example 'line_user_idは一意' do
      user1 = User.create!(line_user_id: '1')
      user2 = User.new(line_user_id: '1')
      expect(user2).to be_invalid
      expect(user2.errors[:line_user_id]).to be_present
    end
    example 'account_registeredのデフォルト値がfalse' do
      user = User.new(line_user_id: '1')
      expect(user.account_registered).to eq(false)
    end
    example 'nameは任意' do
      user = User.new(line_user_id: '1', name: '')
      expect(user).to be_valid
    end
  end

  describe '#weekly_insight_available?' do
    let(:user) { create(:user) }
    let(:now) { Time.zone.parse('2026-01-10 12:00:00') }  # 金曜日

    before do
      Rails.cache.clear  # 各テストの前にキャッシュをクリア
    end

    context 'weekly_insight_generated_atがnilの場合' do
      it 'trueを返す' do
        user.update(weekly_insight_generated_at: nil)

        expect(user.weekly_insight_available?(now: now)).to eq(true)
      end
    end

    context 'タイムスタンプが7日以上前の場合' do
      context 'キャッシュが存在しない場合' do
        it 'trueを返す' do
          user.update(weekly_insight_generated_at: now - 8.days)

          # キャッシュは存在しない（Rails.cache.clearしたので）

          expect(user.weekly_insight_available?(now: now)).to eq(true)
        end
      end

      context 'キャッシュが存在する場合' do
        it 'falseを返す' do
          user.update(weekly_insight_generated_at: now - 8.days)

          # キャッシュをセット
          week_start = (now - 1.week).beginning_of_week.to_date.to_s
          week_key = "weekly_insight_user_#{user.id}_week_#{week_start}"
          Rails.cache.write(week_key, { question: "テスト質問" })

          expect(user.weekly_insight_available?(now: now)).to eq(false)
        end
      end
    end

    context 'タイムスタンプが7日未満の場合' do
      it 'キャッシュに関係なくfalseを返す' do
        user.update(weekly_insight_generated_at: now - 6.days)

        expect(user.weekly_insight_available?(now: now)).to eq(false)
      end
    end
  end
end
