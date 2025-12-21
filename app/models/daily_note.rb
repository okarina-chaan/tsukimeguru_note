class DailyNote < ApplicationRecord
  paginates_per 10

  belongs_to :user

  validates :date, presence: true
  validates :condition_score, presence: true
  validates :mood_score, presence: true

  validates :condition_score, inclusion: { in: 1..5, message: "は1〜5の範囲で選択してください" }
  validates :mood_score, inclusion: { in: 1..5, message: "は1〜5の範囲で選択してください" }

  validates :good_things, length: { maximum: 200, message: "は200文字以内で入力してください" }, allow_blank: true
  validates :try_tomorrow, length: { maximum: 200 }, allow_blank: true
  validates :did_today, length: { maximum: 200 }, allow_blank: true
  validates :challenge, length: { maximum: 200 }, allow_blank: true
  validates :memo, length: { maximum: 1000 }, allow_blank: true

  validates :date, uniqueness: { scope: :user_id, message: "はすでに記入済みです" }
end
