require "rails_helper"

RSpec.describe "Api::WeeklyInsights", type: :request do
  let(:user) { create(:user) }
  let(:reflection_result) do
    {
      summary: "dummy summary",
      advice: "dummy advice",
      trends: [],
      highlights: [
        { type: :return, text: "dummy return message" }
      ]
    }
  end


  describe "POST /api/weekly_insights", type: :request do
    context "未認証のとき" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(nil)
      end
      it "エラーコード401を返す" do
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
      end

      it "キャッシュがなく読み込まれ、201を返す" do
        post "/api/weekly_insights"
        expect(response).to have_http_status(:created)
      end

      it "キャッシュがあり読み込まれたとき、serviceは1回だけ呼び出され、200を返す" do
        service_double = instance_double(Reflection::MockService)

        expect(Reflection::MockService)
          .to receive(:new)
          .once
          .and_return(service_double)

        allow(service_double)
          .to receive(:call)
          .and_return(reflection_result)
        post "/api/weekly_insights"
        expect(response).to have_http_status(:created)

        post "/api/weekly_insights"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/weekly_insights/:id/fragment" do
    let(:week_key) { "weekly_insight_user_#{user.id}_week_2025-12-22" }

    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user)
        .and_return(user)
      Rails.cache.clear
    end

    context "キャッシュがないとき" do
      it "エラーを返す" do
        get "/api/weekly_insights/nonexistent-key/fragment"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "キャッシュがあるとき" do
      before do
        Rails.cache.write(week_key, reflection_result)
      end
      it "partialを返す" do
        get "/api/weekly_insights/#{week_key}/fragment"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/html")
        expect(response.body).to include("今週の変化")
      end
    end
  end
end