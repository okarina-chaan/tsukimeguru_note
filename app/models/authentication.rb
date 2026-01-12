class Authentication < ApplicationRecord
  belongs_to :user

  # emailでの認証のときのみ使う
  has_secure_password validations: false

  validates :provider, presence: true, inclusion: { in: %w[line email] }
  validates :uid, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { provider == "email" }

  # providerとuidの組み合わせは一意
  validates :uid, uniqueness: { scope: :provider }
end
