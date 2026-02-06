FactoryBot.define do
  factory :user do
    sequence(:line_user_id) { |n| "U#{n.to_s.rjust(16, '0')}" }
    name { nil }

    trait :with_account_name do
      name { "テストユーザー" }
    end

    trait :registered do
      name { "登録済みユーザー" }
      account_registered { true }
    end
  end
end
