class User < ApplicationRecord
  validates :line_user_id, presence: true, uniqueness: true
  validates :account_registered, inclusion: { in: [ true, false ] }

    def account_registered?
      name.present?
    end
end
