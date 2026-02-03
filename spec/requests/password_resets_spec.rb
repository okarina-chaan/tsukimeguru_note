require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  describe "POST /password_resets" do
    context "正常系" do
      let(:user) { create(:user, :registered) }

      before do
        user.update!(email: "test@example.com")
      end

      it "正常にパスワードリセットメールが送信されること" do
        post password_resets_path, params: { email: user.email }
        expect(response).to redirect_to(sent_password_resets_path)
        follow_redirect!
        expect(response.body).to include("メールを送信しました")
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([ user.email ])
        expect(mail.subject).to eq("【月めぐるノート】パスワードリセットのご案内")
      end

      it "存在しないメールアドレスでも正常に動作すること" do
        post password_resets_path, params: { email: "not_exist@example.com" }
        expect(response).to redirect_to(sent_password_resets_path)
        follow_redirect!
        expect(response.body).to include("メールを送信しました")
      end
    end

    context "異常系" do
      it "メールアドレスが空の場合にエラーメッセージが表示されること" do
        post password_resets_path, params: { email: "" }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("メールアドレスを入力してください")
      end

      it "1時間に11回以上リクエストした場合にレート制限エラーメッセージが表示されること" do
        user = create(:user, :registered)
        user.update!(email: "ratelimit@example.com")

        11.times do
          post password_resets_path, params: { email: "ratelimit@example.com" }
        end
        post password_resets_path, params: { email: "ratelimit@example.com" }
        expect(response.body).to include("リクエストが多すぎます")
      end
    end
  end

  describe "GET /password_resets/edit" do
    let(:user) { create(:user, :registered, email: "test@example.com") }
    let!(:email_auth) { create(:authentication, :email, user: user, uid: user.email) }
    let(:token) { user.signed_id(expires_in: 30.minutes, purpose: :password_reset) }

    context "正常系" do
      it "パスワードリセットページが表示されること" do
        get edit_password_resets_path(token: token)
        expect(response).to be_successful
      end
    end

    context "異常系" do
      it "無効なトークンの場合にエラーメッセージが表示されること" do
        get edit_password_resets_path(token: "invalid_token")
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("無効")
      end

      it "期限切れのトークンの場合にエラーメッセージが表示されること" do
        expired_token = user.signed_id(expires_in: 30.minutes, purpose: :password_reset)

        travel_to 31.minutes.from_now do
          get edit_password_resets_path(token: expired_token)
          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include("有効期限")
        end
      end
    end
  end

  describe "PATCH /password_resets" do
    let(:user) { create(:user, :registered, email: "test@example.com") }
    let!(:email_auth) { create(:authentication, :email, user: user, uid: user.email) }
    let(:token) { user.signed_id(expires_in: 30.minutes, purpose: :password_reset) }

    context "正常系" do
      it "パスワードが更新されること" do
        patch password_resets_path, params: { token: token, password: "new_password", password_confirmation: "new_password" }
        expect(response).to redirect_to(new_session_path)
        follow_redirect!
        expect(response.body).to include("パスワードをリセットしました")
      end
    end

    context "異常系" do
      it "パスワードと確認用パスワードが一致しない場合にエラーメッセージが表示されること" do
        patch password_resets_path, params: { token: token, password: "new_password", password_confirmation: "mismatch" }
        expect(response.body).to include("パスワードが一致しません")
      end

      it "パスワードが空の場合にエラーメッセージが表示されること" do
        patch password_resets_path, params: { token: token, password: "", password_confirmation: "" }
        expect(response.body).to include("パスワードを入力してください")
      end
    end
  end
end
