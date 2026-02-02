require 'rails_helper'

RSpec.describe "DailyNote", type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    context '正常系' do
      it 'すべての項目が正しく入力されているとき、日記が保存される' do
        daily_note = DailyNote.new(
                                    user:             user,
                                    date:             Time.zone.today,
                                    condition_score:  4,
                                    mood_score:       5,
                                    did_today:       '朝早起きした。',
                                    try_tomorrow:    '今夜も22時には寝る。'
                                  )
        expect(daily_note).to be_valid
      end

      it "異なるユーザーなら同じ日にちで日記を保存できる" do
        other_user = create(:user)
        daily_note1 = create(:daily_note, user: user, date: Time.zone.today)
        daily_note2 = DailyNote.new(
                                    user:             other_user,
                                    date:             Time.zone.today,
                                    condition_score:  3,
                                    mood_score:       4
                                  )

        expect(daily_note2).to be_valid
      end

      it "日付が過去の日でも日記が保存される" do
        daily_note = DailyNote.new(
                                    user:             user,
                                    date:             Time.zone.yesterday,
                                    condition_score:  4,
                                    mood_score:       5
                                  )
        expect(daily_note).to be_valid
      end

      it "体調と気分のスコアがそれぞれ1〜5の範囲内であれば日記が保存される" do
        (1..5).each do |score|
          daily_note = DailyNote.new(
                                      user:             user,
                                      date:             Time.zone.today - score.days,
                                      condition_score:  score,
                                      mood_score:       score
                                    )
          expect(daily_note).to be_valid
        end
      end
    end

    context '異常系' do
      it '体調スコアが未入力のとき、日記が保存されない' do
        daily_note = DailyNote.new(
                                    user:             user,
                                    date:             Time.zone.today,
                                    condition_score:  nil,
                                    mood_score:       5
                                  )
        expect(daily_note).to be_invalid
        expect(daily_note.errors[:condition_score]).to include("を入力してください")
      end

      it '気分スコアが未入力のとき、日記が保存されない' do
        daily_note = DailyNote.new(
                                    user:             user,
                                    date:             Time.zone.today,
                                    condition_score:  4,
                                    mood_score:       nil
                                  )

        expect(daily_note).to be_invalid
        expect(daily_note.errors[:mood_score]).to include("を入力してください")
      end

      it 'ユーザーは同じ日にちで複数の日記を保存できない' do
        daily_note1 = create(:daily_note, user: user, date: Time.zone.today)
        daily_note2 = DailyNote.new(
                                      user:             user,
                                      date:             Time.zone.today,
                                      condition_score:  3,
                                      mood_score:       4
                                    )

        expect(daily_note2).to be_invalid
        expect(daily_note2.errors[:date]).to include("（#{Time.zone.today.strftime('%Y年%m月%d日')}）は既に登録されています")
      end

      it "未来の日付では日記が保存されない" do
        daily_note = DailyNote.new(
                                    user:             user,
                                    date:             Time.zone.tomorrow,
                                    condition_score:  4,
                                    mood_score:       5
                                  )
        expect(daily_note).to be_invalid
        expect(daily_note.errors[:date]).to include("は今日より過去の日付にしてください")
      end

      it '既存の日記を更新する際、他の日記と同じ日付に変更できない' do
        daily_note1 = create(:daily_note, user: user, date: Time.zone.today)
        daily_note2 = create(:daily_note, user: user, date: Time.zone.today - 1.day)

        daily_note2.date = Time.zone.today

        expect(daily_note2).to be_invalid
        expect(daily_note2.errors[:date]).to include("（#{Time.zone.today.strftime('%Y年%m月%d日')}）は既に登録されています")
      end

      it "daily noteの日付以外を編集しても、同じ日付であれば保存できる" do
        daily_note = create(:daily_note, user: user, date: Time.zone.today)

        daily_note.condition_score = 2
        daily_note.mood_score = 3

        expect(daily_note).to be_valid
      end
    end
  end
end
