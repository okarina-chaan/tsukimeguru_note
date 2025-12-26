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

    # 週次分析データの取得
    # 週が変わるごとにキャッシュを切り替える
    week_key = weekly_insight_week_key(current_user, at: Time.zone.now)
    @weekly_insight = Rails.cache.read(week_key)
  end


  # 分析ページを週1回更新できるように制御する
  def weekly_insight
    return redirect_to analysis_path unless current_user.weekly_insight_available?

    # insight生成処理
    # insight生成に失敗した場合はリダイレクトのみ
    # insight生成に成功した場合はキャッシュと更新日時の保存を行う
    insight = fetch_weekly_insight(current_user)

    if insight.blank?
      flash[:alert] = "振り返り内容の生成に失敗しました。日記が記録されているか確認してください。"
      return redirect_to analysis_path
    end

    generated_at = Time.zone.now

    current_user.update!(weekly_insight_generated_at: generated_at)

    week_key = weekly_insight_week_key(current_user, at: generated_at)
    Rails.cache.write(week_key, insight, expires_in: 8.days)

    redirect_to analysis_path
  end

  private

  # キャッシュの生成が必要なときに使用するキーを生成する,今は使わない
  # def weekly_insight_cache_key(user)
  #   stamp = user.weekly_insight_generated_at ? user.weekly_insight_generated_at.beginning_of_day.to_i : "none"
  #   "weekly_insight:user:#{user.id}:#{stamp}"
  # end

  # 週の振り返りデータのキャッシュキーを生成する
  def weekly_insight_week_key(user, at: Time.zone.now)
    week_start = at.beginning_of_week.to_date.to_s
    "weekly_insight:user:#{user.id}:week:#{week_start}"
  end

  def fetch_weekly_insight(user)
    # 月曜日から今日までのデータを取得する
    today = Time.zone.today
    start_date = today.beginning_of_week
    end_date = today
    return nil unless user.daily_notes.where(date: start_date..end_date).exists?

    "これが分析内容になる予定です\n改行しても大丈夫です"
  end
end
