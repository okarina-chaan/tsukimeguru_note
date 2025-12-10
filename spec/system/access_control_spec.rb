require "rails_helper"

RSpec.describe "アクセス制御", type: :system do
  describe "DailyNote" do
    include_examples "require_login", :new_daily_note_path
    include_examples "require_login", :daily_notes_path
  end

  describe "MoonNote" do
    include_examples "require_login", :new_moon_note_path
    include_examples "require_login", :moon_notes_path
  end

  describe "アカウント名編集" do
    include_examples "require_login", :edit_account_name_path
  end

  describe "マイページ" do
    include_examples "require_login", :mypage_path
  end

  describe "分析ページ" do
    include_examples "require_login", :analysis_path
  end

  describe "カレンダー" do
    include_examples "require_login", :calendar_path
  end
end
