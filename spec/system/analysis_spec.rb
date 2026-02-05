require 'rails_helper'

RSpec.describe "Analysis", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers
  let(:user) { create(:user) }

  before { sign_in_as(user) }
  describe '分析ボタンの表示' do
    let(:reflection) { instance_double(Reflection::OpenaiService) }

    context ' 正常系' do
      before do
        allow(Reflection::OpenaiService).to receive(:new).and_return(reflection)
        allow(reflection).to receive(:call).and_return({ "question" => "振り返りの質問", "summary" => "先週のdaily noteの要約" })
      end
      it "押せるときはボタンが有効" do
        user.update!(weekly_insight_generated_at: nil)
        visit analysis_path

        expect(page).to have_button("先週を振り返る", disabled: false)
      end

      it "押したら更新されて次は押せなくなる" do
        user.update!(weekly_insight_generated_at: nil)
        create(:daily_note, user: user, date: Time.zone.today)

        visit analysis_path
        click_button "先週を振り返る"
        expect(page).to have_content("先週を振り返ってみましょう")

        visit analysis_path
        expect(page).to have_button("先週を振り返る", disabled: true)
      end
    end

    context '異常系' do
      it "押せないときはボタンが無効" do
        Rails.cache.write("weekly_insight_user_#{user.id}_week_#{Time.zone.today.beginning_of_week}", {
          "question" => "テスト質問",
          "summary" => "テスト要約"
        })

        travel_to Time.zone.local(2024, 6, 10) do
          user.update!(weekly_insight_generated_at: Time.zone.now.beginning_of_week + 1.day)
          visit analysis_path
          expect(page).to have_button("先週を振り返る", disabled: true)
        end
      end
    end
  end
end
