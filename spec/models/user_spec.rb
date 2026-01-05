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

    context 'weekly_insight_generated_atがnilの場合' do
      it 'trueを返す' do
        user.update(weekly_insight_generated_at: nil)

        expect(user.weekly_insight_available?).to eq(true)
      end
    end

    context '前回生成が今週の場合' do
      it 'falseを返す' do
        # 今週の月曜日に生成したとする
        now = Time.zone.parse('2026-01-10 12:00:00')  # 金曜日
        user.update(weekly_insight_generated_at: now.beginning_of_week)  # 月曜日

        expect(user.weekly_insight_available?(now: now)).to eq(false)
      end

      it '今週の別の曜日に生成した場合もfalseを返す' do
        now = Time.zone.parse('2026-01-10 12:00:00')  # 金曜日
        user.update(weekly_insight_generated_at: now - 2.days)  # 水曜日

        expect(user.weekly_insight_available?(now: now)).to eq(false)
      end
    end

    context '前回生成が先週以前の場合' do
      it 'trueを返す' do
        now = Time.zone.parse('2026-01-10 12:00:00')  # 今週金曜日
        user.update(weekly_insight_generated_at: now - 1.week)  # 先週金曜日

        expect(user.weekly_insight_available?(now: now)).to eq(true)
      end

      it '2週間前でもtrueを返す' do
        now = Time.zone.parse('2026-01-10 12:00:00')
        user.update(weekly_insight_generated_at: now - 2.weeks)

        expect(user.weekly_insight_available?(now: now)).to eq(true)
      end
    end
  end
end
