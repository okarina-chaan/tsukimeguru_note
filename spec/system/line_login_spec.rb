require "rails_helper"

RSpec.describe "LINEログインフロー", type: :system do
  let(:id_token) { "mock_id_token" }
  let(:line_user_id) { "1234567890" }

  before do
    driven_by(:rack_test)
    allow(::LineAuth::TokenService).to receive_message_chain(:new, :exchange_code_for_token).and_return(id_token)
    allow(::LineAuth::IdTokenVerifier).to receive_message_chain(:new, :verify_and_get_user_id).and_return(line_user_id)
  end

  it "新規ユーザーがLINEログインからアカウント登録画面に遷移する" do
    visit root_path

    click_on id: "line-login-btn"

    expect(page.current_url).to include("https://access.line.me/oauth2/v2.1/authorize")

    visit line_login_api_callback_path(code: "auth_code", state: page.current_url.match(/state=([^&]+)/)[1])

    user = User.find_by(line_user_id: line_user_id)
    expect(user).to be_present
    expect(page).to have_current_path(edit_account_name_path)
    expect(page).to have_content("アカウント名を登録してください")
  end

  it "既存ユーザーはダッシュボードに遷移する" do
    create(:user, line_user_id: line_user_id, name: "つきのうさぎ")

    visit line_login_api_login_path

    state = SecureRandom.urlsafe_base64
    page.set_rack_session(state: state)

    visit line_login_api_callback_path(code: "auth_code", state: state)

    expect(page).to have_current_path("/home/dashboard")
    expect(page).to have_content("ログインしました")
  end

  it "stateが不一致の場合はrootに戻る" do
    visit line_login_api_callback_path(code: "auth_code", state: "wrong_state")
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("不正なリクエストです")
  end
end
