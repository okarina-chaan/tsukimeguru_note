class User < ApplicationRecord
  has_many :daily_notes, dependent: :destroy
  has_many :moon_notes, dependent: :destroy
  validates :line_user_id, presence: true, uniqueness: true
  validates :account_registered, inclusion: { in: [ true, false ] }

  def account_registered?
    name.present?
  end

  def weekly_insight_available?(now: Time.zone.now)
    return true if weekly_insight_generated_at.nil?

    # タイムスタンプによる7日制限チェック
    timestamp_check = (now - weekly_insight_generated_at) > 7.days
    return false unless timestamp_check

    # 今週のキャッシュが存在しないことを確認
    week_start = (now - 1.week).beginning_of_week.to_date.to_s
    week_key = "weekly_insight_user_#{id}_week_#{week_start}"
    cached_insight = Rails.cache.read(week_key)
    
    cached_insight.nil?
  end
end
