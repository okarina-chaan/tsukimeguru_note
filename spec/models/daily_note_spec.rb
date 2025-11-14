require 'rails_helper'

RSpec.describe "DailyNote", type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    context '正常系' do
      it 'すべての項目が正しく入力されているとき、日記が保存される' do
        daily_note = DailyNote.new(
          user: user,
          date: Date.current,
          condition_score: 4,
          mood_score: 5,
          did_today: '朝早起きした。',
          try_tomorrow: '今夜も22時には寝る。'
        )
        expect(daily_note).to be_valid
      end
    end
 
    context '異常系' do
      it '体調スコアが未入力のとき、日記が保存されない' do
        daily_note = DailyNote.new(
          user: user,
          date: Date.current,
          condition_score: nil,
          mood_score: 5
        )
        expect(daily_note).to be_invalid
        expect(daily_note.errors[:condition_score]).to include("を入力してください")
      end
      
      it '気分スコアが未入力のとき、日記が保存されない' do
        daily_note = DailyNote.new(
          user: user,
          date: Date.current,
          condition_score: 4,
          mood_score: nil
        )
        expect(daily_note).to be_invalid
        expect(daily_note.errors[:mood_score]).to include("を入力してください")
      end

      it 'ユーザーは同じ日にちで複数の日記を保存できない' do
        daily_note1 = create(:daily_note, user: user, date: Date.current)
        daily_note2 = DailyNote.new(
          user: user,
          date: Date.current,
          condition_score: 3,
          mood_score: 4
        )
        expect(daily_note2).to be_invalid
        expect(daily_note2.errors[:date]).to include("はすでに記入済みです")
      end
    end
  end
end
