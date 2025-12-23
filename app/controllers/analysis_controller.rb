class AnalysisController < ApplicationController
  before_action :require_login

  def show
    # パラメータから年月を取得、なければ今月
    year = params[:year]&.to_i || Date.today.year
    month = params[:month]&.to_i || Date.today.month

    # 指定された年月の1日を基準日とする
    base_date = Date.new(year, month, 1)

    @start_date = base_date.beginning_of_month
    @end_date = base_date.end_of_month

    # 前月・次月の年月を計算
    @prev_date = base_date - 1.month
    @next_date = base_date + 1.month

    # すべての日付を生成
    @dates = (@start_date..@end_date).map(&:to_s)

    # 日記データを取得
    daily_notes = current_user.daily_notes
      .where(date: @start_date..@end_date)
      .index_by(&:date)

    # 各日付に対応するデータを配置
    @moods = @dates.map do |date_str|
      date = Date.parse(date_str)
      daily_notes[date]&.mood_score
    end

    @conditions = @dates.map do |date_str|
      date = Date.parse(date_str)
      daily_notes[date]&.condition_score
    end

    # 月相データ取得
    @moon_markers = MoonApiService.fetch_moon_markers(@start_date, @end_date)

    Rails.logger.debug "📅 Date range: #{@start_date} to #{@end_date}"
    Rails.logger.debug "📊 Total dates: #{@dates.size}"
    Rails.logger.debug "🌙 Moon markers: #{@moon_markers.inspect}"

    @weekly_insight = <<~TEXT
      この1週間では4日分の記録がありました。
      体調・気分スコアは、先週より高い日が多く見られました。
    TEXT
  end
end
