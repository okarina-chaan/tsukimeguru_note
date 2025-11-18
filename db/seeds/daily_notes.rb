require 'faker'

user = User.first

daily_dates = (0..29).to_a.sample(10).map { |d| Date.today - d }

daily_dates.each do |d|
  DailyNote.create!(
    user: user,
    date: d,
    condition_score: rand(1..5),
    mood_score: rand(1..5),
    good_things: Faker::Lorem.sentences(number: 2).join(" "),
    try_tomorrow: Faker::Lorem.sentence(word_count: 10),
    did_today: Faker::Lorem.sentence(word_count: 10),
    challenge: Faker::Lorem.sentence(word_count: 10),
    memo: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

puts "DailyNote のダミーデータ10件作成 "
