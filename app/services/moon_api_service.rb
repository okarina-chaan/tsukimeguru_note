require "net/http"
require "json"

class MoonApiService
  BASE_URL = "http://labs.bitmeister.jp/ohakon/json/"

  SYNODIC_MONTH = 29.530588
  EVENT_RANGES = {
    new_moon:       -0.5..0.5,
    first_quarter_moon:  6.88..7.88,
    full_moon:      14.27..15.27,
    last_quarter_moon:   21.65..22.65
  }

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
    moon_age = angle / 360.0 * SYNODIC_MONTH
    event = detect_event(moon_age)

    {
      date: date,
      angle: angle,
      moon_age: moon_age,
      event: event,
      moon_phase_name: phase_name_for_event(event),
      moon_phase_emoji: phase_emoji(angle)
    }
  rescue => e
    Rails.logger.error("Moon API error: #{e.message}")
    nil
  end

  def self.detect_event(moon_age)
    EVENT_RANGES.each do |event, range|
      return event if range.include?(moon_age)
    end
    nil
  end

  def self.phase_name_for_event(event)
    case event
    when :new_moon          then "新月"
    when :first_quarter_moon then "上弦の月"
    when :full_moon         then "満月"
    when :last_quarter_moon  then "下弦の月"
    else
      "その他の月相"
    end
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
