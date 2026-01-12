class User < ApplicationRecord
  has_many :daily_notes, dependent: :destroy
  has_many :moon_notes, dependent: :destroy
  has_many :authentications, dependent: :destroy
  validates :line_user_id, presence: true, uniqueness: true
  validates :account_registered, inclusion: { in: [ true, false ] }

  def account_registered?
    name.present?
  end

  def weekly_insight_available?(now: Time.zone.now)
    return true if weekly_insight_generated_at.nil?

    # 前回生成した週と今週を比較して、異なる週であれば振り返り機能が使える
    last_generated_week = weekly_insight_generated_at.beginning_of_week
    current_week = now.beginning_of_week
    last_generated_week < current_week
  end
end
