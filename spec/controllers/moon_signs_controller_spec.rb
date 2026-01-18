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
end
