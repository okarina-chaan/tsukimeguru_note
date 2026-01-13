require 'rails_helper'

RSpec.describe 'アカウント削除', type: :system do
  describe '設定ページからアカウント削除' do
    context 'メールアドレス登録済みユーザー' do
      let!(:user) do
        user = User.create!(email: 'user@example.com', line_user_id: 'LINE123', name: '太郎', account_registered: true)
        user.authentications.create!(provider: 'line', uid: 'LINE123')
        user
      end

      before do
        page.set_rack_session(user_id: user.id)
      end

      it 'アカウント削除ボタンが表示される' do
        visit settings_path

        within '.card', text: 'アカウント削除' do
          expect(page).to have_content 'アカウントを削除すると、すべてのデータが削除されます'
          expect(page).to have_button 'アカウントを削除する'
        end
      end

      it 'アカウントを削除できる', js: true do
        visit settings_path

        # 確認ダイアログを自動的に承認する
        accept_confirm do
          click_button 'アカウントを削除する'
        end

        expect(page).to have_content 'アカウントを削除しました'
        expect(page).to have_current_path(root_path)

        # ユーザーが削除されている
        expect(User.find_by(id: user.id)).to be_nil

        # セッションがクリアされている
        expect(page.get_rack_session_key('user_id')).to be_nil
      end

      it '関連データも削除される' do
        # 関連データを作成
        user.daily_notes.create!(date: Date.today)
        user.moon_notes.create!(date: Date.today, moon_age: 1.0, moon_phase: 1, content: 'test')

        visit settings_path

        accept_confirm do
          click_button 'アカウントを削除する'
        end

        # 関連データも削除されている
        expect(user.daily_notes.count).to eq(0)
        expect(user.moon_notes.count).to eq(0)
        expect(user.authentications.count).to eq(0)
      end
    end

    context 'メールアドレス未登録ユーザー' do
      let!(:user) do
        user = User.create!(line_user_id: 'LINE456', name: '次郎', account_registered: true)
        user.authentications.create!(provider: 'line', uid: 'LINE456')
        user
      end

      before do
        page.set_rack_session(user_id: user.id)
      end

      it 'アカウント削除を実行すると、メールアドレス登録を促すメッセージが表示される' do
        visit settings_path

        accept_confirm do
          click_button 'アカウントを削除する'
        end

        expect(page).to have_content '削除連絡用のメールアドレスを登録してください'
        expect(page).to have_current_path(settings_path)

        # ユーザーは削除されていない
        expect(User.find_by(id: user.id)).to be_present
      end
    end

    context 'Email認証のみのユーザー' do
      let!(:user) do
        user = User.create!(email: 'email_only@example.com', name: '三郎', account_registered: true)
        user.authentications.create!(
          provider: 'email',
          uid: 'email_only@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        user
      end

      before do
        page.set_rack_session(user_id: user.id)
      end

      it 'アカウントを削除できる', js: true do
        visit settings_path

        accept_confirm do
          click_button 'アカウントを削除する'
        end

        expect(page).to have_content 'アカウントを削除しました'
        expect(User.find_by(id: user.id)).to be_nil
      end
    end
  end
end
