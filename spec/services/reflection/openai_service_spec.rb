require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Reflection::OpenaiService do
  describe '#call' do
    context 'APIキーが設定されていない場合' do
      let(:user) { create(:user) }
      let(:daily_notes) { create_list(:daily_note, 7, user: user) }

      before do
         stub_env('OPENAI_API_KEY', '')
      end

      it "エラーが表示される" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)

        expect { service.call }.to raise_error(StandardError, "OpenAI API key not found")
      end
    end

    context '日記データが空の場合' do
      let(:user) { create(:user) }
      let(:daily_notes) { [] }
      it "エラーメッセージが表示される" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)
        result = service.call

        expect(result).to eq({ error: "日記データがありません" })
      end
    end

    context 'API呼び出しが成功する' do
      let(:user) { create(:user) }
      let(:daily_notes) { create_list(:daily_note, 7, user: user) }

      before do
        stub_env('OPENAI_API_KEY', 'test_api_key')
        openai_success_request
      end

      it "質問が含まれたハッシュを返す" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)
        result = service.call

        expect(result).to have_key("summary")
        expect(result).to have_key("question")
      end
    end

    context 'API呼び出しがタイムアウトする場合' do
      let(:user) { create(:user) }
      let(:daily_notes) { create_list(:daily_note, 7, user: user) }

      before do
        stub_env('OPENAI_API_KEY', 'test_api_key')
        stub_openai_timeout
      end

      it "タイムアウトエラーメッセージを返す" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)
        result = service.call

        expect(result).to eq({ error: "API呼び出しがタイムアウトしました" })
      end
    end

    context 'API呼び出しで接続に失敗する場合' do
      let(:user) { create(:user) }
      let(:daily_notes) { create_list(:daily_note, 3, user: user) }

      before do
        stub_env('OPENAI_API_KEY', 'test_api_key')
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .to_raise(Faraday::ConnectionFailed)
      end

      it "接続エラーメッセージを返す" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)
        result = service.call

        expect(result).to eq({ error: "OpenAI APIへの接続に失敗しました" })
      end
    end

    context 'API認証に失敗する場合' do
      let(:user) { create(:user) }
      let(:daily_notes) { create_list(:daily_note, 3, user: user) }

      before do
        stub_env('OPENAI_API_KEY', 'test_api_key')
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .to_raise(Faraday::UnauthorizedError)
      end

      it "認証エラーメッセージを返す" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)
        result = service.call

        expect(result).to eq({ error: "OpenAI API認証に失敗しました" })
      end
    end

    context 'レスポンスが無効なJSONの場合' do
      let(:user) { create(:user) }
      let(:daily_notes) { create_list(:daily_note, 3, user: user) }

      before do
        stub_env('OPENAI_API_KEY', 'test_api_key')
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .to_return(
            status: 200,
            body: {
              choices: [
                {
                  message: {
                    content: 'これは無効なJSON'
                  }
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'aaplication/json' }
          )
      end

      it "JSONパースエラーメッセージを返す" do
        service = Reflection::OpenaiService.new(daily_notes: daily_notes)
        result = service.call

        expect(result).to eq({ error: "レスポンスの解析に失敗しました" })
      end
    end
  end
end

def openai_success_request
  WebMock.stub_request(:post, "https://api.openai.com/v1/chat/completions")
  .with(
    headers: {
      'Authorization' => 'Bearer test_api_key',
      'Content-Type' => 'application/json'
    }
  )
  .to_return(
    status: 200,
    body: {
      "choices": [
        {
          "message": {
            content: '{
              "summary": "早起きすることで学習時間を取ることだできたようですね。",
              "question": "早起きすると他にどんなことにつながりますか？"}'
          }
        }
      ]
    }.to_json,
    headers: { 'content-type' => 'application/json' }
  )
end

def stub_openai_timeout
  WebMock.stub_request(:post, "https://api.openai.com/v1/chat/completions")
  .to_raise(Faraday::TimeoutError)
end
