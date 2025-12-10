module NavigationHelper
  def main_nav_items
    [
      { name: "DailyNote", path: daily_notes_path, icon: "pencil-square" },
      { name: "MoonNote", path: moon_notes_path, icon: "moon" },
      { name: "分析", path: analysis_path, icon: "chart-bar" },
      { name: "カレンダー", path: calendar_path, icon: "calendar" },
      { name: "MyPage", path: mypage_path, icon: "user" }
    ]
  end
end
