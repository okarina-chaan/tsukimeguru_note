class DailyNote < ApplicationRecord
  paginates_per 10

  belongs_to :user

  validates  :date,            presence: true
  validates  :condition_score, presence: true
  validates  :mood_score,      presence: true

  validates  :condition_score, inclusion: { in: 1..5, message: "は1〜5の範囲で選択してください" }
  validates  :mood_score,      inclusion: { in: 1..5, message: "は1〜5の範囲で選択してください" }

  validates  :good_things,  length: { maximum: 200, message: "は200文字以内で入力してください" }, allow_blank: true
  validates  :try_tomorrow, length: { maximum: 200 },                               allow_blank: true
  validates  :did_today,    length: { maximum: 200 },                               allow_blank: true
  validates  :challenge,    length: { maximum: 200 },                               allow_blank: true
  validates  :memo,         length: { maximum: 1000 },                              allow_blank: true

  validates  :date, comparison: { less_than_or_equal_to: -> { Time.zone.today } }

  validate   :date_uniqueness_per_user

  private

  def date_uniqueness_per_user
    return if date.blank? || !user_id

    if self.class.exists?(user_id: user_id, date: date) && new_record?
      errors.add(:date, "（#{date.strftime('%Y年%m月%d日')}）は既に登録されています")
    end
  end
end
