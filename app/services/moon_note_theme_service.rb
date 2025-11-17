class MoonNoteThemeService
  THEMES = {
    new_moon: {
      title: "新しい始まり",
      description: "新月はスタートのタイミング。なりたい姿をイメージしましょう"
    },
    first_quarter_moon: {
      title: "吸収と行動",
      description: "上弦の月は行動力が高まるとき。願いを叶えるために取り入れたいことはありますか？"
    },
    full_moon: {
      title: "振り返りと感謝",
      description: "満月は達成や完了のエネルギーが高まります。感謝とともに振り返りましょう。"
    },
    last_quarter_moon: {
      title: "手放しと浄化",
      description: "下弦の月は不要なものをリセットしていくタイミング。手放したいことは何ですか？"
    }
  }

  def self.for(event)
    THEMES[event] || { title: "", description: "" }
  end
end
