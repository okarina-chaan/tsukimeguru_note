require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  describe "GET /dashboard" do
    context "ログインしているユーザー" do
      before do
        # 1月22日のスタブ（現在の日付用）
        stub_request(:get, "http://labs.bitmeister.jp/ohakon/json/?day=22&hour=12.0&mode=moon_phase&month=1&year=2026").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'labs.bitmeister.jp',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: { "date": { "day": "22", "hour": "12.0", "month": "1", "year": "2026" }, "moon_phase": 90.5, "version": "2.2" }.to_json, headers: {})

        # 1月21日のスタブ
        stub_request(:get, "http://labs.bitmeister.jp/ohakon/json/?day=21&hour=12.0&mode=moon_phase&month=1&year=2026").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'labs.bitmeister.jp',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: { "date": { "day": "21", "hour": "12.0", "month": "1", "year": "2026" }, "moon_phase": 85.3, "version": "2.2" }.to_json, headers: {})

        # 1月19日のスタブ（新月）
        stub_request(:get, "http://labs.bitmeister.jp/ohakon/json/?day=19&hour=12.0&mode=moon_phase&month=1&year=2026").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'labs.bitmeister.jp',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: { "date": { "day": "19", "hour": "12.0", "month": "1", "year": "2026" }, "moon_phase": 0.0, "version": "2.2" }.to_json, headers: {})

        # fetch_monthly_events_with_rangeをモックして不要なAPIリクエストを回避
        allow(MoonApiService).to receive(:fetch_monthly_events_with_range).and_return({
          new_moon: [ Date.new(2026, 1, 19) ],
          first_quarter_moon: [],
          full_moon: [],
          last_quarter_moon: []
        })
       end

      it "正常にレスポンスを返す" do
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end

      it "今日の日付が表示される" do
        travel_to Time.zone.local(2026, 1, 21) do
          get dashboard_path
          expect(response.body).to include("2026年 01月 21日")
        end
      end


      it "月相情報が表示される" do
        travel_to Time.zone.local(2026, 1, 19) do
          get dashboard_path
          expect(response.body).to include("新月")
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
        get dashboard_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
