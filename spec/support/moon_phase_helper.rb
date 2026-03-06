module MoonPhaseHelper
  def stub_moon_phase_api
    stub_request(:get, /labs.bitmeister.jp\/ohakon\/json/)
      .to_return(status: 200, body: {
        "angle": 211.49,
        "moon_age": 17.3,
        "phase": 2
      }.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end

RSpec.configure do |config|
  config.include MoonPhaseHelper
end