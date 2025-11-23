require "rails_helper"

RSpec.describe "月星座登録機能", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  it "診断後にユーザーの月星座が保存される" do
    visit new_moon_sign_path

    fill_in "生年月日", with: "1993-06-15"
    fill_in "出生時間（任意）", with: "11:24"
    select "福島県", from: "生誕地（都道府県）"

    click_button "診断する"

    expect(page).to have_content("あなたの月星座")
    expect(page).to have_content("牡羊座").or have_content("不明")

    user.reload
    expect(user.moon_sign).to be_present
  end
end
