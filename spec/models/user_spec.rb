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
  describe 'weekly_insight_available?' do
    context '正常系' do
      example 'weekly_insight_generated_atがnilの場合はtrue' do
        user = User.new(weekly_insight_generated_at: nil)
        expect(user.weekly_insight_available?).to eq(true)
      end
      example 'weekly_insight_generated_atが7日より前の場合はtrue' do
        user = User.new(weekly_insight_generated_at: 8.days.ago)
        expect(user.weekly_insight_available?).to eq(true)
      end
    end
    context '異常系' do
      example 'weekly_insight_generated_atが6日以内の場合はfalse' do
        user = User.new(weekly_insight_generated_at: 6.days.ago)
        expect(user.weekly_insight_available?).to eq(false)
      end
    end
  end
end
