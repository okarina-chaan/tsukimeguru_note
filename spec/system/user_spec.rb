require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe "confirm_destroy" do
    let(:user) { create(:user) }
    let(:token) { user.signed_id(expires_in: 30.minutes, purpose: :destroy_account) }
    let(:url) { confirm_destroy_users_path }

    context "正常系" do
      before do
        sign_in_as(user)
      end
        
      it "正常に確認画面が表示されること" do
        visit mypage_path
        expect(page).to have_content("マイページ")
        click_link "退会する"
        expect(page).to have_content("本当に退会しますか？")
        expect(page).to have_button("退会する")
      end
    end

    context "異常系" do
      let(:no_email_user) { create(:user, email: nil)}
      it "mailがないときはメールアドレス登録画面に遷移すること" do
        sign_in_as(no_email_user)
        visit confirm_destroy_users_path
        click_button "退会する"
        expect(page).to have_content("メールアドレス登録")
      end
    end
  end
  describe "account_destroy" do
    let(:user) { create(:user) }
    let(:token) { user.signed_id(expires_in: 30.minutes, purpose: :destroy_account) }
    let(:url) {destroy_account_users_path(token: token)}
    context "正常系" do
      before do
        sign_in_as(user)
      end
        
      it "正常にアカウントが削除されること" do
        visit url
        expect(page).to have_content("退会の最終確認")
        click_button "退会する"
        expect(page).to have_content("退会完了しました")
        expect(User.find_by(id: user.id)).to be_nil
      end
    end

    context "異常系" do
      it "ログインしていない場合はエラーになること" do
        visit url
        expect(page).to have_content("ログインしてください")
      end

      it "異なるユーザーのトークンの場合はエラーになること" do
        sign_in_as(user)
        other_user = create(:user)
        other_user_token = other_user.signed_id(expires_in: 30.minutes, purpose: :destroy_account)
        visit destroy_account_users_path(token: other_user_token)
        expect(page).to have_content("このリンクはこのアカウントでは使えません")
      end

      it "トークンの有効期限が切れている場合はエラーになること" do
        sign_in_as(user)
        expired_token = user.signed_id(expires_in: 1.second, purpose: :destroy_account)
        travel 2.seconds do
          visit destroy_account_users_path(token: expired_token)
          expect(page).to have_content("このリンクは無効か、有効期限が切れています")
        end
      end
    end
  end
end 