require "rails_helper"

RSpec.describe Reflection::MockService do
  describe "#call" do
    let(:user) { create(:user) }
    let(:daily_notes) { create_list(:daily_note, 7, user: user) }

    it "ハッシュとして返却される" do
      service = Reflection::MockService.new(daily_notes: daily_notes)
      result = service.call

      expect(result).to be_a(Hash)
      expect(result).to have_key(:summary)
      expect(result).to have_key(:advice)
      expect(result).to have_key(:trends)
      expect(result).to have_key(:highlights)

      expect(result[:trends]).to be_a(Hash)
      expect(result[:trends]).to have_key(:condition)
      expect(result[:trends]).to have_key(:mood)
      expect(result[:trends][:condition]).to be_an(Array)
      expect(result[:trends][:mood]).to be_an(Array)
          end

    context "Daily noteが空のとき" do
      let(:daily_notes) { [] }

      it "最低限のハイライトを返す" do
        result = described_class.new(daily_notes: daily_notes).call

        expect(result[:highlights]).to be_an(Array)
        expect(result[:highlights].any? { |h| h[:type] == :return }).to be true
      end
    end
  end
end
