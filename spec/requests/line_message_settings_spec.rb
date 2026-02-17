require "rails_helper"

RSpec.describe "LineMessageSettings", type: :request do
  let(:user) { create(:user, line_user_id: "LINE123") }

  describe "GET /line_message_setting/edit" do
    context "ログインしているユーザー" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)
      end

      it "正常にレスポンスを返す" do
        get edit_line_message_setting_path
        expect(response).to have_http_status(:ok)
      end

      it "設定画面が表示される" do
        get edit_line_message_setting_path
        expect(response.body).to include("LINE通知設定")
      end
    end

    context "ログインしていないユーザー" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(nil)
      end

      it "ログインページにリダイレクトされる" do
        get edit_line_message_setting_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /line_message_setting" do
    context "ログインしているユーザー" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)
      end

      context "有効なパラメータの場合" do
        it "設定を保存してマイページにリダイレクトする" do
          patch line_message_setting_path, params: {
            line_message_setting: {
              new_moon: true,
              first_quarter_moon: false,
              full_moon: true,
              last_quarter_moon: true
            }
          }

          expect(response).to redirect_to(mypage_path)

          user.reload
          expect(user.line_message_setting.new_moon).to be true
          expect(user.line_message_setting.first_quarter_moon).to be false
          expect(user.line_message_setting.full_moon).to be true
          expect(user.line_message_setting.last_quarter_moon).to be true
        end

        it "成功メッセージが表示される" do
          patch line_message_setting_path, params: {
            line_message_setting: {
              new_moon: true,
              first_quarter_moon: false,
              full_moon: true,
              last_quarter_moon: true
            }
          }

          expect(flash[:notice]).to eq("LINE通知の設定を保存しました")
        end
      end

      context "既に設定が存在する場合" do
        before do
          user.create_line_message_setting(
            new_moon: false,
            first_quarter_moon: false,
            full_moon: false,
            last_quarter_moon: false
          )
        end

        it "既存の設定を更新する" do
          patch line_message_setting_path, params: {
            line_message_setting: {
              new_moon: true,
              first_quarter_moon: false,
              full_moon: true,
              last_quarter_moon: false
            }
          }

          user.reload
          expect(user.line_message_setting.new_moon).to be true
          expect(user.line_message_setting.full_moon).to be true
        end
      end
    end

    context "ログインしていないユーザー" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(nil)
      end

      it "ログインページにリダイレクトされる" do
        patch line_message_setting_path, params: {
          line_message_setting: {
            new_moon: true,
            full_moon: true
          }
        }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
