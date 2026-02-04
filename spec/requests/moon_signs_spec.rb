require 'rails_helper'

RSpec.describe "MoonSigns", type: :request do
  let(:user) { create(:user, moon_sign: "牡羊座") }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  describe 'GET /moon_sign' do
    context 'ユーザーが月星座を持っている場合' do
      it '正常にレスポンスを返す' do
        get moon_sign_path(sign: "aries")
        expect(response).to have_http_status(:ok)
      end

      it 'X共有リンクが表示される' do
        get moon_sign_path(sign: "aries")
        expect(response.body).to include("x.com/intent/tweet")
      end

      it 'OGP画像のメタタグが出力される' do
        get moon_sign_path(sign: "aries")
        expect(response.body).to include('og:image')
        expect(response.body).to include('/ogp/')
      end

      it '星座のメッセージが表示される' do
        get moon_sign_path(sign: "aries")
        expect(response.body).to include("情熱的で直感に従うタイプ")
      end
    end

    context 'ユーザーが月星座を持っていない場合' do
      let(:user) { create(:user, moon_sign: nil) }

      it '診断ページにリダイレクトされる' do
        get moon_sign_path
        expect(response).to redirect_to(new_moon_sign_path)
      end
    end
  end
end
