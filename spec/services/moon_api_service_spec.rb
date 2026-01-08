require 'rails_helper'

RSpec.describe MoonApiService do
  describe '.fetch_monthly_events_with_range' do
    let(:year) { 2026 }
    let(:month) { 1 }

  before do
    # スタブ HTTPリクエスト: 1月の全日付
    (1..31).each do |day|
      stub_request(:get, "http://labs.bitmeister.jp/ohakon/json/?day=#{day}&hour=12.0&mode=moon_phase&month=1&year=2026").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'labs.bitmeister.jp',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "", headers: {})
    end

    # テストデータ: 下弦の月が2日間
    MoonPhase.create!(date: Date.new(2026, 1, 10), angle: 264.05, moon_age: 21.7)
    MoonPhase.create!(date: Date.new(2026, 1, 11), angle: 275.16, moon_age: 22.6)
    MoonPhase.create!(date: Date.new(2026, 1, 19), angle: 3.42, moon_age: 0.28)
  end

    it '±7度以内の日を配列で返す' do
      result = MoonApiService.fetch_monthly_events_with_range(year, month)

      expect(result[:last_quarter_moon]).to contain_exactly(
        Date.new(2026, 1, 10),
        Date.new(2026, 1, 11)
      )

      expect(result[:new_moon]).to contain_exactly(
        Date.new(2026, 1, 19)
      )
    end
  end
end
