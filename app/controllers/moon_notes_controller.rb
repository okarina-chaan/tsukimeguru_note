class MoonNotesController < ApplicationController
  before_action :require_login

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

  private

  def moon_note_params
    params.require(:moon_note).permit(:content)
  end
end
