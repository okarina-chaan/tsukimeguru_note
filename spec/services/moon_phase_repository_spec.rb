require 'rails_helper'

RSpec.describe MoonPhaseRepository do
  describe '.fetch_month' do
    let(:year) { 2026 }
    let(:month) { 1 }

    context 'DBにデータがある場合' do
      before do
        # テストデータ作成
        (1..31).each do |day|
          MoonPhase.create!(
            date: Date.new(year, month, day),
            angle: day * 10,
            moon_age: day * 0.5
          )
        end
      end

      it 'DBから取得する' do
        expect(MoonApiService).not_to receive(:fetch)

        result = MoonPhaseRepository.fetch_month(year, month)
        expect(result.size).to eq(31)
      end
    end

    context 'DBにデータがない場合' do
      it 'APIから取得してDBに保存する' do
        # APIをモック
        allow(MoonApiService).to receive(:fetch).and_return(
          date: Date.new(year, month, 1),
          angle: 100.0,
          moon_age: 5.0
        )

        expect {
          MoonPhaseRepository.fetch_month(year, month)
        }.to change(MoonPhase, :count).by(31)
      end
    end
  end
end
