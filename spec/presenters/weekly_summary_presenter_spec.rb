require 'rails_helper'

RSpec.describe WeeklySummaryPresenter do
  let(:user) { create(:user) }
  let(:presenter) { described_class.new(user) }
  let(:start_date) { 1.week.ago.beginning_of_week }
  let(:end_date) { 1.week.ago.end_of_week }

  describe '#count' do
    it 'daily noteが存在しない場合は0を返す' do
      expect(presenter.count).to eq(0)
    end

    it 'daily noteが存在する場合は件数を返す' do
      create(:daily_note, user: user, date: start_date)
      create(:daily_note, user: user, date: start_date + 1.day)

      expect(presenter.count).to eq(2)
    end
  end

  describe '#avg_condition' do
    it 'daily noteが存在しない場合はnilを返す' do
      expect(presenter.avg_condition).to be_nil
    end

    it '平均値を小数点以下1桁で返す' do
      create(:daily_note, user: user, date: start_date, condition_score: 3)
      create(:daily_note, user: user, date: start_date + 1.day, condition_score: 4)

      expect(presenter.avg_condition).to eq(3.5)
    end
  end

  describe '#avg_mood' do
    it 'daily noteが存在しない場合はnilを返す' do
      expect(presenter.avg_mood).to be_nil
    end

    it '平均値を小数点以下1桁で返す' do
      create(:daily_note, user: user, date: start_date, mood_score: 2)
      create(:daily_note, user: user, date: start_date + 1.day, mood_score: 5)

      expect(presenter.avg_mood).to eq(3.5)
    end
  end

  describe '#any?' do
    it 'daily noteが存在しない場合はfalseを返す' do
      expect(presenter.any?).to be false
    end

    it 'daily noteが存在する場合はtrueを返す' do
      create(:daily_note, user: user, date: start_date)

      expect(presenter.any?).to be true
    end
  end
end
