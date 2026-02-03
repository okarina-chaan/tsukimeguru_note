FactoryBot.define do
  factory :authentication do
    association :user
    provider { "line" }
    sequence(:uid) { |n| "U#{n.to_s.rjust(16, '0')}" }

    trait :email do
      provider { "email" }
      sequence(:uid) { |n| "user#{n}@example.com" }
      password { "password123" }
      password_confirmation { "password123" }
    end
  end
end
