require "line/bot"

class LineNotificationService
  def self.client
    Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGE_CHANNEL_SECRET"]
      config.channel_token  = ENV["LINE_MESSAGE_CHANNEL_ID"]
    }
  end

  def self.notify(user, message)
    return unless user.line_user_id.present?

    client.push_message(user.line_user_id, {
      type: "text",
      text: message
    })
  end

  def self.message_for(phase)
    case phase
    when :new_moon
      "今日は新月のMoon Noteの日です。あなたの目標を宣言しましょう。#{ENV['APP_URL']}"
    when :full_moon
      "今日は満月のMoon Noteの日です。これまで頑張ったこと・達成したことを振り返りましょう。#{ENV['APP_URL']}"
    when :first_quarter_moon
      "今日は上弦の月のMoon Noteの日です。あなたの目標に向けて、吸収したいことや挑戦したいことを考えてみましょう！#{ENV['APP_URL']}"
    when :last_quarter_moon
      "今日は下弦の月のMoon Noteの日です。次の目標のために、手放したいことを考えてみましょう！#{ENV['APP_URL']}"
    else
      nil
    end
  end
end
