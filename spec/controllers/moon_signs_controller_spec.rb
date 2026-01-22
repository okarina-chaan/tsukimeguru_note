require 'rails_helper'

RSpec.describe MoonSignsController, type: :controller do
  let(:user) { create(:user, moon_sign: "牡羊座") }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:require_login).and_return(true)
  end

  describe '#ogp_image_url' do
    let(:base_url) { "http://test.host" }

    before do
      allow(controller.request).to receive(:base_url).and_return(base_url)
    end

    context '有効な星座名の場合' do
      it '牡羊座のOGP画像URLを返す' do
        result = controller.send(:ogp_image_url, "牡羊座")
        decoded = URI.decode_www_form_component(result)
        expect(decoded).to eq "http://test.host/ogp/牡羊座.png"
      end

      it '12星座すべてで正しいURLを返す' do
        signs = %w[牡羊座 牡牛座 双子座 蟹座 獅子座 乙女座 天秤座 蠍座 射手座 山羊座 水瓶座 魚座]

        signs.each do |sign|
          result = controller.send(:ogp_image_url, sign)
          decoded = URI.decode_www_form_component(result)
          expect(decoded).to eq "http://test.host/ogp/#{sign}.png"
        end
      end
    end

    context '無効な星座名の場合' do
      it 'nilを返す' do
        result = controller.send(:ogp_image_url, "無効な星座")
        expect(result).to be_nil
      end
    end
  end

  describe '#reverse_translate_sign' do
    it '水瓶座をaquariusに変換する' do
      result = controller.send(:reverse_translate_sign, "水瓶座")
      expect(result).to eq("aquarius")
    end
  end

  describe '#prefecture_to_coords' do
    context '有効な都道府県の場合' do
      it '東京都の座標を返す' do
        result = controller.send(:prefecture_to_coords, '東京都')
        expect(result).to eq([ 35.6895, 139.6917 ])
      end

      it '北海道の座標を返す' do
        result = controller.send(:prefecture_to_coords, '北海道')
        expect(result).to eq([ 43.0642, 141.3469 ])
      end
    end

    context '無効な都道府県の場合' do
      it '存在しない都道府県でデフォルト座標（東京）を返す' do
        result = controller.send(:prefecture_to_coords, '四国')
        expect(result).to eq([ 35.6895, 139.6917 ])
      end
    end
  end

  describe '#translate_sign' do
    context '有効な英語星座名の場合' do
      it 'Ariesを牡羊座に変換する' do
        result = controller.send(:translate_sign, "Aries")
        expect(result).to eq("牡羊座")
      end

      it '12星座すべてで正しく変換する' do
        # TODO: テストを実装
      end
    end

    context '無効な星座名の場合' do
      it '不明な星座名で「不明」を返す' do
        result = controller.send(:translate_sign, "InvalidSign")
        expect(result).to eq("不明")
      end
    end
  end

  describe '#moon_sign_message' do
    it '牡羊座のメッセージを返す' do
      # TODO: テストを実装
    end

    it '12星座すべてでメッセージを返す' do
      # TODO: テストを実装
    end

    it '無効な星座でnilを返す' do
      # TODO: テストを実装
    end
  end

  describe 'POST #create' do
    # テスト用のパラメータ
    let(:valid_params) do
      {
        birth_date: '1990-01-15',
        birth_time: '10:30',
        prefecture: '東京都'
      }
    end

    # APIのURL
    let(:api_url) { 'https://json.freeastrologyapi.com/western/planets' }

    context '外部APIが成功する場合' do
      before do
        # WebMockで外部APIのレスポンスを偽装
        # 月星座が「牡羊座（Aries）」として返ってくる想定
        stub_request(:post, api_url)
          .to_return(
            status: 200,
            body: {
              output: [
                {
                  planet: { en: 'Moon' },
                  zodiac_sign: { name: { en: 'Aries' } }
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it '月星座を診断してユーザーに保存する' do
        # moon_signがまだ設定されていないユーザーでテスト
        user.update(moon_sign: nil)

        post :create, params: valid_params

        # ユーザーの月星座が「牡羊座」に更新されていることを確認
        expect(user.reload.moon_sign).to eq '牡羊座'
      end

      it '診断結果ページにリダイレクトする' do
        post :create, params: valid_params

        expect(response).to redirect_to('/moon_sign/aries')
      end
    end

    context '外部APIが失敗する場合' do
      before do
        # APIがタイムアウトした場合をシミュレート
        stub_request(:post, api_url).to_timeout
      end

      it '診断ページにリダイレクトする' do
        post :create, params: valid_params

        expect(response).to redirect_to(new_moon_sign_path)
      end

      it 'エラーメッセージを表示する' do
        post :create, params: valid_params

        expect(flash[:alert]).to eq('診断に失敗しました。もう一度お試しください。')
      end
    end
  end
end
