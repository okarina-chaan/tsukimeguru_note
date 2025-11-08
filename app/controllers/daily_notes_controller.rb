class DailyNotesController < ApplicationController
  before_action :require_login
  before_action :set_daily_note, only: [ :edit, :update, :destroy ]

  def index
    @daily_notes = current_user.daily_notes.order(date: :desc)
  end

  def new
    @daily_note = current_user.daily_notes.build(date: Date.current)
  end

  def create
    @daily_note = current_user.daily_notes.build(daily_note_params)
    if @daily_note.save
      redirect_to daily_notes_path, notice: "今日の日記を保存しました"
    else
      flash.now[:alert] = "日記の保存に失敗しました"
      render "dashboard/index", status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @daily_note.update(daily_note_params)
      redirect_to dashboard_path, notice: "日記を更新しました"
    else
      flash.now[:alert] = "日記の更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @daily_note.destroy
    redirect_to dashboard_path, notice: "日記を削除しました"
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
