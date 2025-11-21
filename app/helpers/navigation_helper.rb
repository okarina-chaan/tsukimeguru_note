module NavigationHelper
  def main_nav_items
    [
      { name: "DailyNote", path: daily_notes_path, icon: "pencil-square" },
      { name: "MoonNote", path: moon_notes_path, icon: "moon" },
      # { name: "分析", path: analytics_path, icon: "chart-bar" },
      { name: "Settings", path: settings_path, icon: "cog-6-tooth" },
      # { name: "月星座診断", path: moon_signs_path, icon: "star" },
      { name: "MyPage", path: account_name_edit_path, icon: "user" }
    ]
  end
end
