require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'authenticationsを持つ' do
      user = User.create!(line_user_id: 'LINE123')
      auth = user.authentications.create!(provider: 'line', uid: 'LINE123')
      expect(user.authentications).to include(auth)
    end

    it 'daily_notesを持つ' do
      user = User.create!(line_user_id: 'LINE123')
      expect(user).to respond_to(:daily_notes)
    end

    it 'moon_notesを持つ' do
      user = User.create!(line_user_id: 'LINE123')
      expect(user).to respond_to(:moon_notes)
    end
  end

  describe 'validation' do
    context 'line_user_id' do
      it 'NULLを許可する' do
        user = User.new(email: 'test@example.com')
        expect(user).to be_valid
      end

      it '一意である' do
        User.create!(line_user_id: 'LINE123')
        user2 = User.new(line_user_id: 'LINE123')
        expect(user2).to be_invalid
        expect(user2.errors[:line_user_id]).to be_present
      end
    end

    context 'email' do
      it 'NULLを許可する' do
        user = User.new(line_user_id: 'LINE123')
        expect(user).to be_valid
      end

      it '一意である' do
        User.create!(email: 'test@example.com')
        user2 = User.new(email: 'test@example.com')
        expect(user2).to be_invalid
        expect(user2.errors[:email]).to be_present
      end

      it '正しいメールフォーマットである必要がある' do
        user = User.new(email: 'invalid-email')
        expect(user).to be_invalid
        expect(user.errors[:email]).to be_present
      end

      it '有効なメールフォーマット' do
        user = User.new(email: 'valid@example.com')
        expect(user).to be_valid
      end
    end

    example 'account_registeredのデフォルト値がfalse' do
      user = User.new(line_user_id: 'LINE123')
      expect(user.account_registered).to eq(false)
    end

    example 'nameは任意' do
      user = User.new(line_user_id: 'LINE123', name: '')
      expect(user).to be_valid
    end
  end

  describe '#email_authentication' do
    it 'Email認証を返す' do
      user = User.create!(email: 'test@example.com')
      auth = user.authentications.create!(
        provider: 'email',
        uid: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user.email_authentication).to eq(auth)
    end

    it 'Email認証がない場合nilを返す' do
      user = User.create!(line_user_id: 'LINE123')
      expect(user.email_authentication).to be_nil
    end
  end

  describe '#line_authentication' do
    it 'LINE認証を返す' do
      user = User.create!(line_user_id: 'LINE123')
      auth = user.authentications.create!(provider: 'line', uid: 'LINE123')
      expect(user.line_authentication).to eq(auth)
    end

    it 'LINE認証がない場合nilを返す' do
      user = User.create!(email: 'test@example.com')
      expect(user.line_authentication).to be_nil
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

  describe "ユーザーが退会したとき" do
    it "ユーザーが削除される" do
      user = create(:user, email: "test@example.com")
      expect { user.destroy }.to change { User.count }.by(-1)
    end

    it "関連する認証情報も削除される" do
      user = create(:user, email: "test@example.com")
      user.authentications.create!(provider: "email", uid: "test@example.com", password: "password123", password_confirmation: "password123")
      expect { user.destroy }.to change { Authentication.count }.by(-1)
    end

    it "関連するdaily noteも削除される" do
      user = create(:user, email: "test@example.com")
      user.daily_notes.create!(date: Time.zone.today, condition_score: 3, mood_score: 4)
      expect { user.destroy }.to change { DailyNote.count }.by(-1)
    end

    it "関連するmoon noteも削除される" do
      user = create(:user, email: "test@example.com")
      user.moon_notes.create!(date: Time.zone.today, moon_phase: "full_moon", moon_age: 14.3, content: "満月で気分が高まった。")
      expect { user.destroy }.to change { MoonNote.count }.by(-1)
    end
  end
end
