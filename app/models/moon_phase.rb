class MoonPhase < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :angle, presence: true
  validates :moon_age, presence: true

  # daily_notes 用：7段階の月相名
  def display_name
    MoonApiService.phase_name(angle)
  end

  def display_emoji
    MoonApiService.phase_emoji(angle)
  end

  # moon_notes 用：厳密なイベント判定
  def strict_event
    MoonApiService.detect_event(angle, MoonApiService::STRICT_EVENT_TOLERANCE_DEGREES)
  end

  # moon_notes 用：緩いイベント判定
  def loose_event
    MoonApiService.detect_event(angle, MoonApiService::LOOSE_EVENT_TOLERANCE_DEGREES)
  end

  # moon_notes 作成可能か
  def creatable_for_moon_note?
    loose_event.present?
  end
end
