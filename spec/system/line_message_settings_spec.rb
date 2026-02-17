require 'rails_helper'

RSpec.describe 'LineMessageSettings', type: :system, js: true do
  let(:user) { create(:user, line_user_id: "LINE123") }

  before do
    sign_in_as(user)
  end

  describe 'マイページからLINE通知設定画面へ' do
    it 'マイページに「設定する」ボタンが表示されること' do
      visit mypage_path
      expect(page).to have_content 'LINE通知設定'
      expect(page).to have_link '設定する'
    end

    it '設定画面に遷移できること' do
      visit mypage_path
      click_on '設定する'
      expect(page).to have_current_path edit_line_message_setting_path
      expect(page).to have_content 'LINE通知設定'
    end
  end

  describe 'LINE通知設定の保存' do
    it '月相をチェックして保存できること' do
      visit edit_line_message_setting_path

      check '新月'
      check '満月'
      uncheck '上弦の月'
      uncheck '下弦の月'

      click_on '設定する'

      expect(page).to have_current_path mypage_path
      expect(page).to have_content 'LINE通知の設定を保存しました'
    end

    it '保存後、設定が保持されていること' do
      visit edit_line_message_setting_path

      check '新月'
      check '満月'
      click_on '設定する'

      visit edit_line_message_setting_path

      expect(page).to have_checked_field '新月'
      expect(page).to have_checked_field '満月'
      expect(page).to have_unchecked_field '上弦の月'
      expect(page).to have_unchecked_field '下弦の月'
    end
  end

  describe 'LINE未連携ユーザー' do
    let(:user_without_line) { create(:user, line_user_id: nil) }

    before do
      sign_in_as(user_without_line)
    end

    it 'マイページに「LINE連携する」ボタンが表示されること' do
      visit mypage_path
      expect(page).to have_content 'LINE通知設定'
      expect(page).to have_content 'LINE通知を受け取るには、LINEアカウントとの連携が必要です'
      expect(page).to have_link 'LINE連携をする'
    end

    it '設定画面にアクセスできること（新規作成の場合）' do
      visit edit_line_message_setting_path
      expect(page).to have_content 'LINE通知設定'
    end
  end
end
