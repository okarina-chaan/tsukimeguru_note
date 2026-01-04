require 'faker'

user = User.first

daily_dates = (0..29).to_a.sample(10).map { |d| Date.today - d }

daily_dates.each do |d|
  DailyNote.create!(
    user: user,
    date: d,
    condition_score: rand(1..5),
    mood_score: rand(1..5),
    good_things: Faker::Lorem.paragraph,
    try_tomorrow: Faker::Lorem.paragraph,
    did_today: Faker::Lorem.paragraph,
    challenge: Faker::Lorem.paragraph,
    memo: Faker::Lorem.paragraph
  )
end

puts "DailyNote のダミーデータ10件作成 "
