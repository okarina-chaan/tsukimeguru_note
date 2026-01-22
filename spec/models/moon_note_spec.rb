require "rails_helper"

RSpec.describe "Moon Note", type: :model do
  let(:user) { create(:user) }

  context "バリデーション" do
    it "正常系: 正しく入力されているとき、Moon Noteが保存される" do
      moon_note = MoonNote.new(
        user: user,
        date: Time.zone.today,
        moon_phase: "full_moon",
        moon_age: 14.3,
        content: "満月で気分が高まった。"
      )
      expect(moon_note).to be_valid
    end

    it "異常系: contentが未入力のとき、Moon Noteが保存されない" do
      moon_note = MoonNote.new(
        user: user,
        date: Time.zone.today,
        moon_phase: "new_moon",
        moon_age: 0.0,
        content: nil
      )
      expect(moon_note).to be_invalid
    end
  end
end
