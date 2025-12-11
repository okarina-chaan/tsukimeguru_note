class MoonNote < ApplicationRecord
  MOON_PHASE_EVENTS = {
    new_moon: 0,
    first_quarter_moon: 1,
    full_moon: 2,
    last_quarter_moon: 3
  }.freeze unless const_defined?(:MOON_PHASE_EVENTS)

  belongs_to :user

  validates :date, presence: true
  validates :moon_age, presence: true
  validates :moon_phase, presence: true
  validates :content, presence: true, length: { maximum: 1000 }

  enum :moon_phase, MOON_PHASE_EVENTS

  def effective_moon_phase
    loose_moon_phase.presence || moon_phase
  end

  def loose_moon_phase
    value = self[:loose_moon_phase]
    return if value.nil?

    MOON_PHASE_EVENTS.key(value)&.to_s
  end

  def loose_moon_phase=(phase)
    self[:loose_moon_phase] =
      case phase
      when nil, ""
        nil
      when Integer
        phase
      else
        key = phase.to_sym
        MOON_PHASE_EVENTS.fetch(key)
      end
  end
end
