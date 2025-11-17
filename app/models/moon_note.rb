class MoonNote < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :moon_age, presence: true
  validates :moon_phase, presence: true
  validates :content, presence: true, length: { maximum: 1000 }

  enum :moon_phase, {
    new_moon: 0,
    first_quarter_moon: 1,
    full_moon: 2,
    last_quarter_moon: 3
  }
end
