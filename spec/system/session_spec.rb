require "rails_helper"

RSpec.describe "セッション管理", type: :system do
  include LineAuthStub

  before do
    driven_by(:selenium_chrome_headless)
  end

  it "LINEログインしてからログアウトできる" do
    user = User.create!(line_user_id: "U1234567890abcdef", name: "テストユーザー", account_registered: true)
    user.authentications.create(provider: "line", uid: "U1234567890abcdef")
    stub_line_auth

    visit root_path

    click_link "ログイン", match: :first
    find("a[href='/line_login_api/login']", visible: :all, match: :first).click

    expect(page).to have_current_path(dashboard_path)

    click_on "ログアウト"
    expect(page).to have_current_path(root_path)
  end
end
