class Authentication < ApplicationRecord
  belongs_to :user

  # emailでの認証のときのみ使う
  has_secure_password validations: false

  validates :provider, presence: true, inclusion: { in: %w[line email] }
  validates :uid, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { provider == "email" }
  validates :password_confirmation, presence: true, if: -> { provider == "email" && password.present? }
  validate  :password_match, if: -> { provider == "email" && password.present? && password_confirmation.present? }

  # providerとuidの組み合わせは一意
  validates :uid, uniqueness: { scope: :provider }

  private

  def password_match
    if password != password_confirmation
      errors.add(:password_confirmation, "がパスワードと一致しません")
    end
  end
end
