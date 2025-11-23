require "net/http"
require "json"

class MoonApiService
  BASE_URL = "http://labs.bitmeister.jp/ohakon/json/"

  SYNODIC_MONTH = 29.530588
  DEGREES_PER_DAY = 360.0 / SYNODIC_MONTH
  EVENT_TOLERANCE_DAYS = 1.0
  EVENT_TOLERANCE_DEGREES = DEGREES_PER_DAY * EVENT_TOLERANCE_DAYS
  EVENT_ANGLE_CENTERS = {
    new_moon: 0.0,
    first_quarter_moon: 90.0,
    full_moon: 180.0,
    last_quarter_moon: 270.0
  }.freeze

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

    # 角度ベースで判定
    event = detect_event(angle)

    event_name = phase_name_for_event(event)

    {
      date: date,
      angle: angle,
      moon_age: moon_age,
      event: event,
      moon_phase_name: event_name || phase_name(angle),
      moon_phase_emoji: phase_emoji(angle)
    }
  rescue => e
    Rails.logger.error("Moon API error: #{e.message}")
    nil
  end

  def self.detect_event(angle)
    normalized = angle % 360

    EVENT_ANGLE_CENTERS.each do |event, center|
      return event if angular_difference(normalized, center) <= EVENT_TOLERANCE_DEGREES
    end
    nil
  end

  def self.angular_difference(value, target)
    diff = (value - target).abs
    [ diff, 360 - diff ].min
  end

  def self.phase_name_for_event(event)
    case event
    when :new_moon           then "新月"
    when :first_quarter_moon then "上弦の月"
    when :full_moon          then "満月"
    when :last_quarter_moon  then "下弦の月"
    else
      nil
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
