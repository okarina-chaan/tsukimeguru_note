class User < ApplicationRecord
  has_many :daily_notes, dependent: :destroy
  has_many :moon_notes, dependent: :destroy
  has_many :authentications, dependent: :destroy

  # line_user_idはnullable（email認証ユーザーはNULL）
  validates :line_user_id, uniqueness: true, allow_nil: true

  # emailもnullable（LINE認証ユーザーは任意）
  validates :email, uniqueness: true, allow_nil: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :account_registered, inclusion: { in: [ true, false ] }

  def account_registered?
    name.present?
  end

  # ヘルパーメソッド
  def email_authentication
    authentications.find_by(provider: 'email')
  end

  def line_authentication
    authentications.find_by(provider: 'line')
  end

  def weekly_insight_available?(now: Time.zone.now)
    return true if weekly_insight_generated_at.nil?

    # 前回生成した週と今週を比較して、異なる週であれば振り返り機能が使える
    last_generated_week = weekly_insight_generated_at.beginning_of_week
    current_week = now.beginning_of_week
    last_generated_week < current_week
  end
end
