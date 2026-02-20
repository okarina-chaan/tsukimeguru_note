require "line/bot"

class LineNotificationService
  def self.client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV["LINE_MESSAGING_API_CHANNEL_ACCESS_TOKEN"]
    )
  end

  def self.notify(user, message)
    return unless user.line_user_id.present?

    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: user.line_user_id,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(
          type: "text",
          text: message
        )
      ]
    )
    client.push_message(push_message_request: push_request)
  end
end
