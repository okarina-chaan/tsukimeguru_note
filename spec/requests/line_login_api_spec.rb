require 'rails_helper'

RSpec.describe "LineLoginApi", type: :request do
  describe "POST /line_login_api/callback" do
    let(:line_user_id) { "1234567890" }

    before do
      allow_any_instance_of(LineLoginApiController)
        .to receive(:exchange_code_for_token)
        .and_return("mock_id_token")
      allow_any_instance_of(LineLoginApiController)
        .to receive(:verify_id_token_and_get_sub)
        .and_return(line_user_id)
      allow_any_instance_of(LineLoginApiController)
        .to receive(:session)
        .and_return({ state: "test_state" })
    end

    context '新規ユーザーの場合' do
      it '新しいユーザーが作成されること' do
        expect {
          post line_login_api_callback_path, params: { code: 'auth_code', state: "test_state" }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(edit_account_name_path)
      end
    end

    context '既存ユーザー（account_registered: true）の場合' do
      let!(:user) { User.create!(line_user_id: line_user_id, name: "餅つきラビット", account_registered: true) }

      it 'ダッシュボードにリダイレクトすること' do
        post line_login_api_callback_path, params: { code: 'auth_code', state: "test_state" }
        expect(response).to redirect_to(dashboard_path) # または home_dashboard_path
      end
    end

    context '既存ユーザー（account_registered: false）の場合' do
      let!(:user) { User.create!(line_user_id: line_user_id, account_registered: false) }

      it 'アカウント名登録ページにリダイレクトすること' do
        post line_login_api_callback_path, params: { code: 'auth_code', state: "test_state" }
        expect(response).to redirect_to(edit_account_name_path)
      end
    end
  end
end
