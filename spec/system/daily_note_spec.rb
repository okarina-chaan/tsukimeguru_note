require 'rails_helper'

RSpec.describe "日記作成", type: :system do
  let(:user) { create(:user) }

  before do
    WebMock.allow_net_connect!
    sign_in_as(user)
  end
after { WebMock.disable_net_connect!(allow_localhost: true) }

  it "ユーザーが日記を作成できる" do
    visit dashboard_path

    find("button[data-value='5'][data-action*='selectHealth']").click
    find("button[data-value='4'][data-action*='selectMood']").click
    click_button "保存する"
    expect(page).to have_content("日記を保存しました")
    expect(DailuNNote.count).to eq(1)
  end

  it "バリデーションエラー時は保存されない" do
    visit dashboard_path

    click_button "保存する"
    expect(page).to have_content("体調スコアを入力してください")
    expect(page).to have_content("気分スコアを入力してください")
    expect(DailyNote.count).to eq(0)
  end
end
