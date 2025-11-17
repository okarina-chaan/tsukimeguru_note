module NavigationHelper
  def main_nav_items
    [
      { name: "Daily", path: daily_notes_path, icon: "pencil-square" },
      { name: "Moon", path: moon_notes_path, icon: "moon" }
      # { name: "分析", path: analytics_path, icon: "chart-bar" },
      # { name: "設定", path: settings_path, icon: "cog-6-tooth" }
    ]
  end
end
