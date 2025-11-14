require "net/http"
require "json"

class MoonApiService
  BASE_URL = "http://labs.bitmeister.jp/ohakon/json/"

  def self.fetch(date = Date.today)
    year  = date.year
    month = date.month
    day   = date.day
    hour  = 12.0

    uri = URI("#{BASE_URL}?mode=moon_phase&year=#{year}&month=#{month}&day=#{day}&hour=#{hour}")
    response = Net::HTTP.get(uri)
    Rails.logger.info("Moon API raw response: #{response}")

    data = JSON.parse(response)
    angle = data["moon_phase"].to_f % 360.0

    {
      date: date,
      moon_phase_angle: angle,
      moon_phase_name: phase_name(angle),
      moon_phase_emoji: phase_emoji(angle)
    }
  rescue => e
    Rails.logger.error("Moon API error: #{e.message}")
    nil
  end

  def self.phase_name(angle)
    case angle
    when 0...45   then "新月"
    when 45...90  then "三日月"
    when 90...135 then "上弦の月"
    when 135...180 then "十三夜"
    when 180...225 then "満月"
    when 225...270 then "下弦の月"
    when 270...315 then "有明月"
    else "新月"
    end
  end

  def self.phase_emoji(angle)
    case angle
    when 0...45   then "🌑"
    when 45...90  then "🌒"
    when 90...135 then "🌓"
    when 135...180 then "🌔"
    when 180...225 then "🌕"
    when 225...270 then "🌗"
    when 270...315 then "🌘"
    else "🌑"
    end
  end
end
