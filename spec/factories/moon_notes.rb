FactoryBot.define do
  factory :moon_note do
    association :user
    sequence(:date) { |n| Date.current - n.days }
    moon_phase { :full_moon }
    moon_age { 14.8 }
    content { "今日は満月です。心が穏やかになります。" }
  end
end
