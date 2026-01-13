require 'rails_helper'

RSpec.describe 'メールアドレス登録', type: :system do
  let!(:user) do
    user = User.create!(line_user_id: 'LINE123', name: 'LINE太郎', account_registered: true)
    user.authentications.create!(provider: 'line', uid: 'LINE123')
    user
  end

  before do
    # ユーザーとしてログイン
    page.set_rack_session(user_id: user.id)
  end

  describe '設定ページからメールアドレス登録' do
    context 'メールアドレス未登録の場合' do
      it '未登録と表示され、登録リンクがある' do
        visit settings_path

        within '.card', text: 'メールアドレス' do
          expect(page).to have_content '未登録'
          expect(page).to have_link '登録する'
        end
      end

      it 'メールアドレスを登録できる' do
        visit settings_path

        click_link '登録する'

        expect(page).to have_current_path(edit_email_path)
        expect(page).to have_content 'アカウント削除時の連絡用です'

        fill_in 'メールアドレス', with: 'line_user@example.com'
        click_button '登録する'

        expect(page).to have_content 'メールアドレスを登録しました'
        expect(page).to have_current_path(settings_path)

        # ユーザーのemailが更新されている
        expect(user.reload.email).to eq('line_user@example.com')
      end

      it 'キャンセルボタンで設定ページに戻れる' do
        visit edit_email_path

        click_link 'キャンセル'

        expect(page).to have_current_path(settings_path)
      end
    end

    context 'メールアドレス登録済みの場合' do
      before do
        user.update!(email: 'registered@example.com')
      end

      it '登録済みメールアドレスが表示され、変更リンクがある' do
        visit settings_path

        within '.card', text: 'メールアドレス' do
          expect(page).to have_content 'registered@example.com'
          expect(page).to have_link '変更する'
        end
      end

      it 'メールアドレスを変更できる' do
        visit settings_path

        click_link '変更する'

        expect(page).to have_current_path(edit_email_path)

        fill_in 'メールアドレス', with: 'updated@example.com'
        click_button '登録する'

        expect(page).to have_content 'メールアドレスを登録しました'
        expect(user.reload.email).to eq('updated@example.com')
      end
    end

    context 'バリデーションエラー' do
      it '無効なメールフォーマットの場合、エラーが表示される' do
        visit edit_email_path

        fill_in 'メールアドレス', with: 'invalid-email'
        click_button '登録する'

        expect(page).to have_content 'メールアドレスの登録に失敗しました'
      end

      it '既に使用されているメールアドレスの場合、エラーが表示される' do
        User.create!(email: 'taken@example.com')

        visit edit_email_path

        fill_in 'メールアドレス', with: 'taken@example.com'
        click_button '登録する'

        expect(page).to have_content 'メールアドレスの登録に失敗しました'
      end
    end
  end
end
