require "net/http"
require "json"

class MoonApiService
  BASE_URL = "http://labs.bitmeister.jp/ohakon/json/"

  SYNODIC_MONTH = 29.530588
  DEGREES_PER_DAY = 360.0 / SYNODIC_MONTH

  # MoonNote 用（ ±1日で月相を取り扱い、MoonNoteを書きやすくする）
  LOOSE_EVENT_TOLERANCE_DEGREES = DEGREES_PER_DAY * 0.8

  # Dashboard 用（ 正確な月相を返す ）
  STRICT_EVENT_TOLERANCE_DEGREES = 5.5

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

    data = JSON.parse(response)

    angle = data["moon_phase"].to_f % 360.0
    moon_age = angle / 360.0 * SYNODIC_MONTH

    # Dashboard 用：正確なイベント判定
    strict_event = detect_event(angle, STRICT_EVENT_TOLERANCE_DEGREES)

    # MoonNote 用：ゆるいイベント判定
    loose_event = detect_event(angle, LOOSE_EVENT_TOLERANCE_DEGREES)

    {
      date: date,
      angle: angle,
      moon_age: moon_age,
      event: strict_event,                       # Dashboard はこれを使う
      loose_event: loose_event,                  # MoonNote はこれを使う
      loose_event_name: phase_name_for_event(loose_event),
      moon_phase_name: phase_name(angle),        # 基本の月相名称
      moon_phase_emoji: phase_emoji(angle)
    }
  rescue => e
    nil
  end


  # strict / loose 両方で使える汎用 event 判定
  def self.detect_event(angle, tolerance)
    return nil if angle.nil?

    normalized = angle % 360

    EVENT_ANGLE_CENTERS.each do |event, center|
      return event if angular_difference(normalized, center) <= tolerance
    end

    nil
  end


  def self.angular_difference(value, target)
    diff = (value - target).abs
    [ diff, 360 - diff ].min
  end


  # event → 日本語表記（Dashboardとmoon note両方で使う）
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


  # 通常の月相名称
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
    # イベント判定（±7度）
    event = detect_event(angle, 7.0)

    return "🌑" if event == :new_moon
    return "🌓" if event == :first_quarter_moon
    return "🌕" if event == :full_moon
    return "🌗" if event == :last_quarter_moon

    # イベントに該当しない場合は、従来の範囲判定
    normalized = angle % 360
    case normalized
    when 0...45, 338..360  then "🌑"
    when 45...90   then "🌒"
    when 90...135  then "🌓"
    when 135...180 then "🌔"
    when 180...225 then "🌕"
    when 225...270 then "🌖"
    when 270...338 then "🌘"
    else "🌑"
    end
  end

  # MoonNote 作成可否（ゆるい）
  def self.creatable_moon_note?(angle)
    return false if angle.nil?

    detect_event(angle, LOOSE_EVENT_TOLERANCE_DEGREES).present?
  end

  # グラフ用の月相を取得
  def self.fetch_moon_markers(start_date, end_date)
    year = start_date.year
    month = start_date.month

    moon_phases = MoonPhaseRepository.fetch_month(year, month)
    moon_marks = []
    # 満月と新月のときにアノテーションを表示させたい
    moon_phases.each do |moon_phase|
      event = detect_event(moon_phase.angle, STRICT_EVENT_TOLERANCE_DEGREES)
      if event == :new_moon
        moon_marks << { date: moon_phase.date.to_s, type: "new_moon", emoji: "🌑" }
      elsif event == :full_moon
        moon_marks << { date: moon_phase.date.to_s, type: "full_moon", emoji: "🌕️" }
      end
    end
    moon_marks
  end

  def self.fetch_monthly_events_with_range(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    moon_phases = MoonPhaseRepository.fetch_month(year, month)

    events = {
      new_moon: [],
      first_quarter_moon: [],
      full_moon: [],
      last_quarter_moon: []
    }

    EVENT_ANGLE_CENTERS.each do |event, target_angle|
      moon_phases.each do |moon_phase|
        diff = angular_difference(moon_phase.angle % 360, target_angle)

        # ±7度（約半日分）以内なら該当
        events[event] << moon_phase.date if diff <= 7.0
      end
    end

    events
  end
end
