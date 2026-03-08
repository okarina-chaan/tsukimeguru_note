module MoonPhaseHelper
  def stub_moon_phase_api
    stub_request(:get, /labs.bitmeister.jp\/ohakon\/json/)
      .to_return(status: 200, body: {
        "angle": 211.49,
        "moon_age": 17.3,
        "phase": 2
      }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def create_moon_phases(start_date, end_date)
    (start_date..end_date).each do |date|
      MoonPhase.create!(
        date: date,
        angle: rand(0..360),
        moon_age: rand(0..29)
      )
    end
  end
end

RSpec.configure do |config|
  config.include MoonPhaseHelper
end
