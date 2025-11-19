class MoonNotesController < ApplicationController
  before_action :require_login
  before_action :set_moon_note, only: %i[edit update]
  before_action :set_moon_theme, only: %i[edit update]

  def index
    @moon_notes = current_user.moon_notes.order(date: :desc)
  end

  def new
    @moon_note = current_user.moon_notes.build
    data = MoonApiService.fetch(Date.today)
    if data[:event].blank?
      redirect_to dashboard_path, alert: "今日のMoon Noteはありません。"
    else
      @moon_note.moon_phase = data[:event]
      @moon_phase_name = data[:moon_phase_name]
      @moon_phase_emoji = data[:moon_phase_emoji]
      @moon_age = data[:moon_age]

    theme = MoonNoteThemeService.for(data[:event])
      @moon_theme = theme[:title]
      @moon_theme_description = theme[:description]
      flash.now[:notice] = "今日は#{data[:moon_phase_name]}です。Moon Noteを作成しましょう！"
      render :new
    end
  end

  def create
    data = MoonApiService.fetch(Date.today)
    return redirect_to dashboard_path if data.nil? || data[:event].blank?
    return redirect_to dashboard_path, alert: "今日のMoon Noteは作成済みです" if current_user.moon_notes.exists?(date: data[:date])
    @moon_note = current_user.moon_notes.build(moon_note_params)
    @moon_note.moon_phase = data[:event]
    @moon_note.date = data[:date]
    @moon_note.moon_age = data[:moon_age]
    if @moon_note.save
      redirect_to dashboard_path, notice: "Moon Noteを保存しました"
    else
      flash.now[:alert] = "Moon Noteの保存に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @moon_note.update(moon_note_params)
      redirect_to moon_notes_path, notice: "Moon Noteを更新しました"
    else
      render :edit, status: :unprocessable_entity
      alert = "Moon Noteの更新に失敗しました"
    end
  end

  private

  def moon_note_params
    params.require(:moon_note).permit(:content)
  end

  def set_moon_note
   @moon_note = current_user.moon_notes.find(params[:id])
  end

  def set_moon_theme
    @moon_theme = MoonNoteThemeService.for(@moon_note.moon_phase.to_sym)
  end
end
