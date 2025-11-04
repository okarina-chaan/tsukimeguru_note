require "rails_helper"

RSpec.describe "LineLogin", type: :system do
  before do
    driven_by(:rack_test)
    allow_any_instance_of(LineLoginApiController)
      .to receive(:exchange_code_for_token)
      .and_return("mock_id_token")
    allow_any_instance_of(LineLoginApiController)
      .to receive(:verify_id_token_and_get_sub)
      .and_return("1234567890")
  end

  context "新規ユーザーの場合" do
    it "アカウント名登録画面に遷移すること" do
      visit line_login_api_callback_path(code: "auth_code", state: "test_state")
      expect(page).to have_current_path(edit_account_name_path)
      expect(page).to have_content("アカウント名を登録してください")
      expect(User.count).to eq(1)
    end
  end

  context "既存ユーザー（account_registered: true）の場合" do
    let!(:user) { User.create!(line_user_id: "1234567890", name: "餅つきラビット", account_registered: true) }

    it "ダッシュボードに遷移すること" do
      sign_in_as(user)
      visit line_login_api_callback_path(code: "auth_code", state: "test_state")
      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_content("ログインしました")
    end
  end

  context "既存ユーザー（account_registered: false）の場合" do
    let!(:user) { User.create!(line_user_id: "1234567890", name: nil, account_registered: false) }

    it "アカウント名登録画面に遷移すること" do
      visit line_login_api_callback_path(code: "auth_code", state: "test_state")
      expect(page).to have_current_path(edit_account_name_path)
      expect(page).to have_content("アカウント名を登録してください")
    end
  end
end
