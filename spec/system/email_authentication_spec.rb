require 'rails_helper'

RSpec.describe 'Email認証', type: :system do
  describe '新規登録' do
    it 'メールアドレスとパスワードで新規登録できる' do
      visit new_registration_path

      fill_in 'メールアドレス', with: 'newuser@example.com'
      fill_in 'パスワード（6文字以上）', with: 'password123'
      fill_in 'パスワード（確認）', with: 'password123'

      click_button '登録する'

      expect(page).to have_content 'アカウントを作成しました'
      expect(page).to have_content 'アカウント名を登録'
      expect(page).to have_current_path(edit_account_name_path)

      # ユーザーとEmail認証が作成されている
      user = User.find_by(email: 'newuser@example.com')
      expect(user).to be_present
      expect(user.email_authentication).to be_present
      expect(user.email_authentication.uid).to eq('newuser@example.com')
    end

    it 'パスワードが短い場合、エラーが表示される' do
      visit new_registration_path

      fill_in 'メールアドレス', with: 'newuser@example.com'
      fill_in 'パスワード（6文字以上）', with: '12345'
      fill_in 'パスワード（確認）', with: '12345'

      click_button '登録する'

      expect(page).to have_content '登録に失敗しました'
      expect(User.find_by(email: 'newuser@example.com')).to be_nil
    end

    it 'パスワード確認が一致しない場合、エラーが表示される' do
      visit new_registration_path

      fill_in 'メールアドレス', with: 'newuser@example.com'
      fill_in 'パスワード（6文字以上）', with: 'password123'
      fill_in 'パスワード（確認）', with: 'different123'

      click_button '登録する'

      expect(page).to have_content '登録に失敗しました'
      expect(User.find_by(email: 'newuser@example.com')).to be_nil
    end

    it 'ログインページへのリンクがある' do
      visit new_registration_path

      click_link 'ログインはこちら'

      expect(page).to have_current_path(new_session_path)
    end
  end

  describe 'ログイン' do
    let!(:user) do
      user = User.create!(email: 'existing@example.com', name: 'テストユーザー', account_registered: true)
      user.authentications.create!(
        provider: 'email',
        uid: 'existing@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      user
    end

    it 'メールアドレスとパスワードでログインできる' do
      visit new_session_path

      fill_in 'メールアドレス', with: 'existing@example.com'
      fill_in 'パスワード', with: 'password123'

      click_button 'ログイン'

      expect(page).to have_content 'ログインしました'
      expect(page).to have_current_path(dashboard_path)
    end

    it '間違ったパスワードの場合、エラーが表示される' do
      visit new_session_path

      fill_in 'メールアドレス', with: 'existing@example.com'
      fill_in 'パスワード', with: 'wrongpassword'

      click_button 'ログイン'

      expect(page).to have_content 'メールアドレスまたはパスワードが正しくありません'
      expect(page).to have_current_path(session_path)
    end

    it '存在しないメールアドレスの場合、エラーが表示される' do
      visit new_session_path

      fill_in 'メールアドレス', with: 'nonexistent@example.com'
      fill_in 'パスワード', with: 'password123'

      click_button 'ログイン'

      expect(page).to have_content 'メールアドレスまたはパスワードが正しくありません'
    end

    it '新規登録ページへのリンクがある' do
      visit new_session_path

      click_link '新規登録はこちら'

      expect(page).to have_current_path(new_registration_path)
    end
  end

  describe 'ホームページからのアクセス' do
    it 'メールアドレス新規登録ボタンが表示される' do
      visit root_path

      expect(page).to have_link 'メールアドレスで新規登録'
      click_link 'メールアドレスで新規登録'

      expect(page).to have_current_path(new_registration_path)
    end

    it 'メールアドレスログインボタンが表示される' do
      visit root_path

      expect(page).to have_link 'メールアドレスでログイン'
      click_link 'メールアドレスでログイン'

      expect(page).to have_current_path(new_session_path)
    end
  end
end
