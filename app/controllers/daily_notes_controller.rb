class DailyNotesController < ApplicationController
  before_action :require_login
  before_action :set_daily_note, only: %i[edit update destroy]

  def index
    @daily_note ||= current_user.daily_notes.build
    @daily_notes = current_user.daily_notes.order(date: :desc)
  end

  def new
    @daily_note = current_user.daily_notes.build(date: Date.current)
  end

  def create
    @daily_note = current_user.daily_notes.build(daily_note_params)
    moon_data = MoonApiService.fetch(@daily_note.date)
    if moon_data.present?
      @daily_note.moon_phase_name = moon_data[:moon_phase_name]
      @daily_note.moon_phase_emoji = moon_data[:moon_phase_emoji]
    end
    if @daily_note.save
      redirect_to daily_notes_path, notice: "日記を保存しました", status: :see_other
    else
      @daily_notes = current_user.daily_notes.order(date: :desc)
      flash.now[:alert] = "日記の保存に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @daily_note.update(daily_note_params)
      redirect_to daily_notes_path, notice: "日記を更新しました", status: :see_other
    else
      flash.now[:alert] = "日記の更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
      @daily_note.destroy
      redirect_to daily_notes_path, notice: "日記を削除しました"
  end

  private

  def set_daily_note
    @daily_note = current_user.daily_notes.find(params[:id])
  end

  def daily_note_params
    params.require(:daily_note).permit(
      :condition_score,
      :mood_score,
      :did_today,
      :try_tomorrow,
      :challenge,
      :good_things,
      :memo
    ).merge(date: Date.current)
  end
end
