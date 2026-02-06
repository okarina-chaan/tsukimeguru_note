require "rails_helper"

RSpec.describe "WeeklyInsight integration", type: :request do
  let(:user) { create(:user) }
  let!(:daily_notes) { create_list(:daily_note, 7, user: user) }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)

    Rails.cache.clear
    stub_env('OPENAI_API_KEY', 'test_api_key')
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(
                  status: 200,
                  body: {
                    choices: [ {
                        message: {
                          content: '{"question": "早起きについてどう感じますか？", "summary": "早起きすることで学習時間を確保しようとしていましたね"}'
                        }
                      } ]
                    }.to_json,
                  headers: { 'Content-Type' => 'application/json' }
                )
  end

  it "POST → GET fragment で振り返りHTMLを取得できる" do
    # POST: 振り返り生成
    post "/api/weekly_insights"
    expect(response).to have_http_status(:created).or have_http_status(:ok)

    id = JSON.parse(response.body)["id"]
    expect(id).to be_present

    # GET: fragment取得
    get "/api/weekly_insights/#{id}/fragment"
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/html")
    expect(response.body).to include("早起きについてどう感じますか？")
  end
end
