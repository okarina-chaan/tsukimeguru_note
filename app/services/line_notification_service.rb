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
    client.push_message(push_request)
  end
end

class MoonNoteMessageService
  def self.message_for(phase)
    case phase
    when :new_moon
      "今日は新月のMoon Noteの日です。\nあなたの目標を宣言しましょう。\n#{ENV['APP_URL']}"
    when :full_moon
      "今日は満月のMoon Noteの日です。\nこれまで頑張ったこと・達成したことを振り返りましょう。\n#{ENV['APP_URL']}"
    when :first_quarter_moon
      "今日は上弦の月のMoon Noteの日です。\nあなたの目標に向けて、吸収したいことや挑戦したいことを考えてみましょう！\n#{ENV['APP_URL']}"
    when :last_quarter_moon
      "今日は下弦の月のMoon Noteの日です。\n次の目標のために、手放したいことを考えてみましょう！\n#{ENV['APP_URL']}"
    else
      nil
    end
  end
end
