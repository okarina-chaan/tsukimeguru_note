require 'rails_helper'

RSpec.describe "カレンダー", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe "カレンダー画面" do
    context "表示" do
      it "カレンダーが表示される" do
        visit calendar_path
        expect(page).to have_content("Moon Phase Calendar")
      end
    end

    context "月移動" do
      it "前の月に移動できる" do
        visit calendar_path(year: 2025, month: 3)
        find("#prev-month").click

        expect(page).to have_content("2025年 2月")
      end

      it "次の月に移動できる" do
        visit calendar_path(year: 2025, month: 3)
        find("#next-month").click

        expect(page).to have_content("2025年 4月")
      end
    end

    context "月の満ち欠け表示" do
      it "Moon APIから取得した月の満ち欠け情報が表示される" do
        allow(MoonApiService).to receive(:fetch).and_return(
          { moon_phase_name: "満月", moon_phase_emoji: "🌕", moon_phase_angle: 180.0, event: :full_moon }
        )
        visit calendar_path
        expect(page).to have_content("満月")
      end
    end
  end

  describe "カレンダーページでのローディングアニメーション" do
    it "ローディングアニメーションが表示される" do
      visit calendar_path
      find("#next-month").click

      expect(page).to have_css(
        '[data-controller="loading"]:not(.hidden)',
        wait: 2
      )
    end
  end
end
