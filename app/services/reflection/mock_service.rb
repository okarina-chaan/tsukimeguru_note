module Reflection
  class MockService
    def initialize(daily_notes: )
      @daily_notes = daily_notes
    end

    def call
      {
        summary: "先週は新月から上弦の月へ移り変わる週でした。物事の吸収が高まりやすい時期です。",
        advice: "記入したDaily notesは5件で、平均の気分スコアや体調スコアは比較的高かったです。",
        trends: {
          condition: [3, 4, 2, 3, 1],
          mood: [4, 3, 3, 2, 2]
        },
        highlights: [
          { type: :period, value: "新月→上弦の月" },
          { type: :count, value: 5 },
          { type: :trend, value: :neutral },
          { type: :return, value: true },
        ]
      }
    end
  end
end