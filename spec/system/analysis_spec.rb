require 'rails_helper'

RSpec.describe "Analysis", type: :system, js: true do
  let(:user) { create(:user) }

  before { sign_in_as(user) }
  describe '分析ボタンの表示' do
    context ' 正常系' do
      it "押せるときはボタンが有効" do
        user.update!(weekly_insight_generated_at: nil)
        visit analysis_path

        expect(page).to have_button("今週の変化をみる", disabled: false)
      end

      it "押したら更新されて次は押せなくなる" do
        user.update!(weekly_insight_generated_at: nil)
        visit analysis_path

        click_button "今週の変化をみる"

        visit analysis_path
        expect(page).to have_button("今週の変化をみる", disabled: true)
      end
    end
    context '異常系' do
      it "押せないときはボタンが無効" do
        user.update!(weekly_insight_generated_at: Time.zone.now)
        visit analysis_path

        expect(page).to have_button("今週の変化をみる", disabled: true)
      end
    end
  end
end
