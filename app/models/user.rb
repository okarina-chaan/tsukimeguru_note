class User < ApplicationRecord
  has_many :daily_notes, dependent: :destroy
  has_many :moon_notes, dependent: :destroy
  validates :line_user_id, presence: true, uniqueness: true
  validates :account_registered, inclusion: { in: [ true, false ] }

  def account_registered?
    name.present?
  end
end
