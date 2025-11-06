require 'rails_helper'

RSpec.describe LineAuth::TokenService do
  describe '#exchange_code_for_token' do
    it '成功したときにid_tokenを返す' do
      stub_request(:post, "https://api.line.me/oauth2/v2.1/token")
        .to_return(status: 200, body: { id_token: "fake_token" }.to_json)

      service = described_class.new
      token = service.exchange_code_for_token(code: "authcode", redirect_uri: "http://localhost:3000/callback")

      expect(token).to eq "fake_token"
    end
  end
end

