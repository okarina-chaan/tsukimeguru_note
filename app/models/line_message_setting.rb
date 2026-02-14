class LineMessageSetting < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true

  # ユーザーのLINEメッセージ設定について、月相ごとに有効なものだけ取得するスコープ
  scope :enabled_for_phase, ->(phase) { where(phase => true) }
end
