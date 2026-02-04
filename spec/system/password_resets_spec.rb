require "rails_helper"

RSpec.describe "パスワードリセット", type: :system do
  describe "パスワードリセット申請" do
    let(:user) { create(:user, :registered, email: "test@example.com") }
    let!(:email_auth) { create(:authentication, :email, user: user, uid: user.email) }

    context "正常系" do
      it "パスワードリセット申請ページにアクセスできる" do
        visit new_password_reset_path

        expect(page).to have_content("パスワードリセット")
        expect(page).to have_field("メールアドレス")
      end

      it "登録済みのメールアドレスでリセット申請ができる" do
        visit new_password_reset_path

        fill_in "メールアドレス", with: user.email
        click_button "案内メールを送信する"

        expect(page).to have_current_path(sent_password_resets_path)
        expect(page).to have_content("メールを送信しました")
      end

      it "未登録のメールアドレスでも正常にリダイレクトされる" do
        visit new_password_reset_path

        fill_in "メールアドレス", with: "unknown@example.com"
        click_button "案内メールを送信する"

        expect(page).to have_current_path(sent_password_resets_path)
        expect(page).to have_content("メールを送信しました")
      end
    end

    context "異常系" do
      it "メールアドレスが空の場合エラーが表示される" do
        visit new_password_reset_path

        fill_in "メールアドレス", with: ""
        click_button "案内メールを送信する"

        expect(page).to have_content("メールアドレスを入力してください")
      end
    end
  end

  describe "パスワード変更" do
    let(:user) { create(:user, :registered, email: "test@example.com") }
    let!(:email_auth) { create(:authentication, :email, user: user, uid: user.email) }
    let(:token) { user.signed_id(expires_in: 30.minutes, purpose: :password_reset) }

    context "正常系" do
      it "パスワードリセットページにアクセスできる" do
        visit edit_password_resets_path(token: token)
        expect(page).to have_content("パスワードリセット設定")
        expect(page).to have_content("パスワード（6文字以上）")
        expect(page).to have_content("パスワード（確認）")
      end

      it "パスワードを変更できる" do
        visit edit_password_resets_path(token: token)

        fill_in "password", with: "new_password"
        fill_in "password_confirmation", with: "new_password"
        click_button "パスワードをリセットする"

        expect(page).to have_content("パスワードをリセットしました")
        expect(page).to have_current_path(new_session_path)
      end

      it "変更後のパスワードでログインできる" do
        visit edit_password_resets_path(token: token)

        fill_in "password", with: "new_password"
        fill_in "password_confirmation", with: "new_password"
        click_button "パスワードをリセットする"

        # 新しいパスワードでログイン
        fill_in "email", with: user.email
        fill_in "password", with: "new_password"
        click_button "ログイン"

        expect(page).to have_content("ログインしました")
      end
    end

    context "異常系" do
      it "パスワードが空の場合エラーが表示される" do
        visit edit_password_resets_path(token: token)

        fill_in "password", with: ""
        fill_in "password_confirmation", with: ""
        click_button "パスワードをリセットする"

        expect(page).to have_content("パスワードを入力してください")
      end

      it "パスワード確認が一致しない場合エラーが表示される" do
        visit edit_password_resets_path(token: token)

        fill_in "password", with: "new_password"
        fill_in "password_confirmation", with: "different_password"
        click_button "パスワードをリセットする"

        expect(page).to have_content("パスワードが一致しません")
      end

      it "無効なトークンの場合エラーが表示される" do
        visit edit_password_resets_path(token: "invalid_token")

        expect(page).to have_content("無効")
      end

      it "期限切れのトークンの場合エラーが表示される" do
        expired_token = user.signed_id(expires_in: 30.minutes, purpose: :password_reset)

        travel_to 31.minutes.from_now do
          visit edit_password_resets_path(token: expired_token)

          expect(page).to have_content("有効期限")
        end
      end
    end
  end

  describe "パスワードリセットの全体フロー" do
    let(:user) { create(:user, :registered, email: "test@example.com") }
    let!(:email_auth) { create(:authentication, :email, user: user, uid: user.email) }
    let(:token) { user.signed_id(expires_in: 30.minutes, purpose: :password_reset) }

    it "申請からパスワード変更までの一連の流れが正常に動作する" do
      # 1. パスワードリセット申請
      visit new_password_reset_path
      fill_in "email", with: user.email
      click_button "案内メールを送信する"

      expect(page).to have_current_path(sent_password_resets_path)
      expect(page).to have_content("メールを送信しました")

      # 2. リセットメールからパスワード変更ページへ（トークンを直接使用）
      visit edit_password_resets_path(token: token)

      # 3. 新しいパスワードを設定
      fill_in "password", with: "new_password"
      fill_in "password_confirmation", with: "new_password"
      click_button "パスワードをリセットする"

      expect(page).to have_content("パスワードをリセットしました")
    end
  end
end
