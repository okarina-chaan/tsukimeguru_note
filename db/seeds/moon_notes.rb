require "faker"

user = User.first || User.create!(
  name: "Test User",
  line_user_id: "test_line_user_id"
)


moon_phases = MoonNote.moon_phases.keys
moon_dates = (0..29).to_a.sample(10).map { |d| Date.today - d }

moon_dates.each do |d|
  user.moon_notes.create!(
    date: d,
    moon_phase: moon_phases.sample,
    moon_age: rand(0.0..29.5),
    content: Faker::Lorem.paragraph(sentence_count: 5)
  )
end

puts "MoonNote のダミーデータ10件作成 "
