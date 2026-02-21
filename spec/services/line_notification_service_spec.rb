require "rails_helper"
require "line/bot"

RSpec.describe LineNotificationService do
  describe ".notify" do
    let(:mock_client) { double("Line::Bot::Client") }

    before do
      allow(LineNotificationService).to receive(:client).and_return(mock_client)
      allow(mock_client).to receive(:push_message)
    end

    it "line_user_idがあるユーザーにpush_messageが呼ばれる" do
      user = create(:user, line_user_id: "LINE123")
      LineNotificationService.notify(user, "テストメッセージ")
      expect(mock_client).to have_received(:push_message).with(push_message_request: instance_of(Line::Bot::V2::MessagingApi::PushMessageRequest))
    end

    it "line_user_idがないユーザーにはpush_messageが呼ばれない" do
      user = create(:user, line_user_id: nil)
      LineNotificationService.notify(user, "テストメッセージ")
      expect(mock_client).not_to have_received(:push_message)
    end
  end
end
