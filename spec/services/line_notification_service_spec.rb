require "rails_helper"
require "line/bot"

RSpec.describe LineNotificationService do
    describe ".message_for" do
    it "新月のときは新月のMoon Noteの日のメッセージが返る" do
      expect(MoonNoteMessageService.message_for(:new_moon)).to include("新月のMoon Noteの日")
    end

    it "満月のときは満月のMoon Noteの日のメッセージが返る" do
      expect(MoonNoteMessageService.message_for(:full_moon)).to include("満月のMoon Noteの日")
    end

    it "上弦の月のときは上弦の月のMoon Noteの日のメッセージが返る" do
      expect(MoonNoteMessageService.message_for(:first_quarter_moon)).to include("上弦の月のMoon Noteの日")
    end

    it "下弦の月のときは下弦の月のMoon Noteの日のメッセージが返る" do
      expect(MoonNoteMessageService.message_for(:last_quarter_moon)).to include("下弦の月のMoon Noteの日")
    end

    it "不明なフェーズのときはnilが返る" do
      expect(MoonNoteMessageService.message_for(:unknown_phase)).to be_nil
    end
  end

  describe ".notify" do
    let(:mock_client) { double("Line::Bot::Client") }

    before do
      allow(LineNotificationService).to receive(:client).and_return(mock_client)
      allow(mock_client).to receive(:push_message)
    end

    it "line_user_idがあるユーザーにpush_messageが呼ばれる" do
      user = create(:user, line_user_id: "LINE123")
      LineNotificationService.notify(user, "テストメッセージ")
      expect(mock_client).to have_received(:push_message).with(instance_of(Line::Bot::V2::MessagingApi::PushMessageRequest))
    end

    it "line_user_idがないユーザーにはpush_messageが呼ばれない" do
      user = create(:user, line_user_id: nil)
      LineNotificationService.notify(user, "テストメッセージ")
      expect(mock_client).not_to have_received(:push_message)
    end
  end
end
