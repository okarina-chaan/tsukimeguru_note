FactoryBot.define do
  factory :daily_note do
    association :user, factory: :user
    sequence(:date, Date.current)
    condition_score { 3 }
    mood_score { 3 }
    good_things { "今日の良いことを書きます。" }
    try_tomorrow { "明日やってみることを書きます。" }
  end
end
