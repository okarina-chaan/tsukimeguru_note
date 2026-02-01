class DailyNotesController < ApplicationController
  before_action :require_login
  before_action :set_daily_note, only: %i[edit update destroy]

  def index
    @daily_note ||= current_user.daily_notes.build
    @daily_notes = current_user.daily_notes.order(date: :desc).page params[:page]
  end

  def new
    if params[:date].blank?
      @daily_note = current_user.daily_notes.build
      return
    end

    # 日付のフォーマットをチェックして検証
    begin
      selected_date = Date.parse(params[:date])
    rescue ArgumentError
      flash[:error] = "無効な日付です"
      @daily_note   = current_user.daily_notes.build
      return
    end

    # 既存のDaily Noteをチェックしてエラーを出すか新規作成するか決定
    # rubocop:disable Style/RedundantReturn
    @daily_note = current_user.daily_notes.find_by(date: selected_date)

    if @daily_note
      flash.now[:error] = "#{selected_date.strftime('%Y年%m月%d日')}のDaily Noteは既に存在します"
      @daily_note = current_user.daily_notes.build(date: selected_date)
      return
    else
      @daily_note = current_user.daily_notes.build(date: selected_date)
    end
  end
  # rubocop:enable Style/RedundantReturn

  def create
    @daily_note = current_user.daily_notes.build(daily_note_params)
    moon_data = MoonApiService.fetch(@daily_note.date)
    if moon_data.present?
      @daily_note.moon_phase_name  = moon_data[:moon_phase_name]
      @daily_note.moon_phase_emoji = moon_data[:moon_phase_emoji]
    end
    if @daily_note.save
      redirect_to daily_notes_path, notice: "Daily noteを保存しました", status: :see_other
    else
      @daily_notes      = current_user.daily_notes.order(date: :desc)
      flash.now[:alert] = "Daily noteの保存に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @daily_note = current_user.daily_notes.find(params[:id])
  end

  def update
    if @daily_note.update(daily_note_params)
      redirect_to daily_notes_path, notice: "Daily noteを更新しました", status: :see_other
    else
      flash.now[:alert] = "Daily noteの更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
      @daily_note.destroy
      redirect_to daily_notes_path, notice: "Daily noteを削除しました"
  end

  private

  def set_daily_note
    @daily_note = current_user.daily_notes.find(params[:id])
  end

  def daily_note_params
    params.require(:daily_note).permit(
      :date,
      :condition_score,
      :mood_score,
      :did_today,
      :try_tomorrow,
      :challenge,
      :good_things,
      :memo
    )
  end
end
