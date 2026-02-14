require 'rails_helper'

RSpec.describe LineMessageSetting, type: :model do
  describe 'バリデーション' do
    it 'LINEユーザーIDは必須である' do
      line_message_setting = LineMessageSetting.new
      expect(line_message_setting).to_not be_valid
      expect(line_message_setting.errors[:user]).to include("を入力してください")

      user = User.create!(name: 'Test User', line_user_id: 'LINE123')
      line_message_setting = LineMessageSetting.new(user: user)
      expect(line_message_setting).to be_valid
    end

    it '同じユーザーは複数のLINEメッセージの通知設定ができない' do
      user = User.create!(name: 'Test User', line_user_id: 'LINE123')
      LineMessageSetting.create!(user: user)

      duplicate_line_message_setting = LineMessageSetting.new(user: user)
      expect(duplicate_line_message_setting).to_not be_valid
      expect(duplicate_line_message_setting.errors[:user_id]).to include("はすでに存在します")
    end

    describe "スコープ" do
      let(:user1) { User.create!(name: 'User1', line_user_id: 'LINE1') }
      let(:user2) { User.create!(name: 'User2', line_user_id: 'LINE2') }

      it "新月の通知が有効なユーザーのみを返す" do
        setting1 = LineMessageSetting.create!(user: user1, new_moon: true)
        setting2 = LineMessageSetting.create!(user: user2, new_moon: false)

        expect(LineMessageSetting.enabled_for_phase(:new_moon)).to include(setting1)
        expect(LineMessageSetting.enabled_for_phase(:new_moon)).to_not include(setting2)
      end

      it "満月の通知が有効なユーザーのみを返す" do
        setting1 = LineMessageSetting.create!(user: user1, full_moon: true)
        setting2 = LineMessageSetting.create!(user: user2, full_moon: false)

        expect(LineMessageSetting.enabled_for_phase(:full_moon)).to include(setting1)
        expect(LineMessageSetting.enabled_for_phase(:full_moon)).to_not include(setting2)
      end

      it "上弦の月の通知が有効なユーザーのみを返す" do
        setting1 = LineMessageSetting.create!(user: user1, first_quarter_moon: true)
        setting2 = LineMessageSetting.create!(user: user2, first_quarter_moon: false)

        expect(LineMessageSetting.enabled_for_phase(:first_quarter_moon)).to include(setting1)
        expect(LineMessageSetting.enabled_for_phase(:first_quarter_moon)).to_not include(setting2)
      end

      it "下弦の月の通知が有効なユーザーのみを返す" do
        setting1 = LineMessageSetting.create!(user: user1, last_quarter_moon: true)
        setting2 = LineMessageSetting.create!(user: user2, last_quarter_moon: false)

        expect(LineMessageSetting.enabled_for_phase(:last_quarter_moon)).to include(setting1)
        expect(LineMessageSetting.enabled_for_phase(:last_quarter_moon)).to_not include(setting2)
      end
    end
  end
end
