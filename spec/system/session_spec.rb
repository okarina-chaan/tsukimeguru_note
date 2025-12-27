require "rails_helper"

RSpec.describe "セッション管理", type: :system do
  include LineAuthStub

  before do
    driven_by(:selenium_chrome_headless)
  end

  it "LINEログインしてからログアウトできる" do
    User.create!(line_user_id: "U1234567890abcdef", name: "テストユーザー", account_registered: true)
    stub_line_auth

    visit root_path

    find("a[href='/line_login_api/login']", visible: :all, match: :first).click

    expect(page).to have_current_path(dashboard_path)

    click_on "ログアウト"
    expect(page).to have_current_path(root_path)
  end
end
