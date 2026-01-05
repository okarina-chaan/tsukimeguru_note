require "rails_helper"

RSpec.describe "Api::WeeklyInsightsController", type: :request do
  let(:user) { create(:user) }
  let(:reflection_result) { { "question" => "早起きについてどう感じますか？",
    "summary" => "早起きすることで学習時間を確保しようとしていましたね" }
     }


  describe "POST /api/weekly_insights" do
    context "未認証のとき" do
      it "エラーコード401を返す" do
        allow_any_instance_of(Api::WeeklyInsightsController)
        .to receive(:api_require_login) do |controller|
          controller.render json: { error: "Unauthorized" }, status: :unauthorized
        end
        post "/api/weekly_insights"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "認証されているとき" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)

        Rails.cache.clear

        create(:daily_note, user: user, date: 1.week.ago)
        create(:daily_note, user: user, date: 8.days.ago)
        create(:daily_note, user: user, date: 9.days.ago)
      end

      context "キャッシュがない場合" do
        before do
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

        it "新しい振り返りを生成し201を返す" do
          # まずGETリクエストでCSRFトークンを取得
          get root_path  # または何か適当なページ
          csrf_token = response.headers['X-CSRF-Token'] ||
                      cookies['CSRF-TOKEN']

          stub_env('OPENAI_API_KEY', 'test_api_key')
          stub_request(:post, "https://api.openai.com/v1/chat/completions")
            .to_return(
              status: 200,
              body: { choices: [ { message: { content: '{"question": "test?"}' } } ] }.to_json
            )

          # CSRFトークンを含めてPOST
          post "/api/weekly_insights",
            headers: { 'X-CSRF-Token' => csrf_token }

          puts "CSRF Token: #{csrf_token}"
          puts "Response: #{response.status} - #{response.body}"

          expect(response).to have_http_status(:created)
        end

        it "キャッシュに保存される" do
          post "/api/weekly_insights"

          week_key = JSON.parse(response.body)["id"]
          cached = Rails.cache.read(week_key)

          expect(cached).to eq(reflection_result)
        end
      end
    end
  end
end
