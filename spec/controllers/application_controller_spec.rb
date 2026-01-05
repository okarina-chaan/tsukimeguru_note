require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:user) { create(:user, id: 123) }

  describe '#weekly_insight_week_key' do
    it '基準日から週の開始日を計算して一意のキーを生成する' do
      base_date = Date.parse('2026-01-05') # 日曜日
      expected_week_start = base_date.beginning_of_week.to_s
      expected_key = "weekly_insight_user_123_week_#{expected_week_start}"

      result = controller.send(:weekly_insight_week_key, user, at: base_date)
      expect(result).to eq(expected_key)
    end

    it 'デフォルトで1週間前の日付を基準とする' do
      expected_week_start = (Time.zone.today - 1.week).beginning_of_week.to_date.to_s
      expected_key = "weekly_insight_user_123_week_#{expected_week_start}"

      result = controller.send(:weekly_insight_week_key, user)
      expect(result).to eq(expected_key)
    end

    it '異なるユーザーIDで異なるキーを生成する' do
      another_user = create(:user, id: 456)
      base_date = Date.parse('2026-01-05')

      key1 = controller.send(:weekly_insight_week_key, user, at: base_date)
      key2 = controller.send(:weekly_insight_week_key, another_user, at: base_date)

      expect(key1).to include('user_123')
      expect(key2).to include('user_456')
      expect(key1).not_to eq(key2)
    end

    it '異なる週で異なるキーを生成する' do
      date1 = Date.parse('2026-01-05')
      date2 = Date.parse('2026-01-12')

      key1 = controller.send(:weekly_insight_week_key, user, at: date1)
      key2 = controller.send(:weekly_insight_week_key, user, at: date2)

      expect(key1).not_to eq(key2)
    end
  end
end
