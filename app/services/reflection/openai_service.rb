module Reflection
  class OpenAiService
    def initialize(daily_notes:)
      @daily_notes = daily_notes
    end

    def new
    end

    def call
      prompt = <<-PROMPT
      あなたはユーザーが先週1週間で書いた日記を読んで、書き手自身が深く振り返るための「問い」を投げかける役割です。
      評価や助言は一切せず、書き手が自分で考えを深められるような質問を1つ提示してください。

      # 日記の内容
       これらは事実データです。解釈することは禁止します。
      - ユーザーはここで今日行動して良かった・成功したと思えたことを書いています
      #{daily_note.good_things}
      - ユーザーはここで明日やりたいことを書いています
      #{daily_note.try_tomorrow}
      - ユーザーはここで今日なにを行動したのかを書いています
      #{daily_note.did_today}
      - ユーザーはここで、うまく行かなかったことを書いています
      #{daily_note.challenge}
      - ユーザーはここで、上記で書ききれなかった内容について書いています
      #{daily_note.memo}

      # 出力
      {
        question: “....?”
      }

      # 重要な制約
       - 日記の内容を評価したり、アドバイスしたりしないでください
       - 「良い」「悪い」などの価値判断を含めないでください
       - 書き手が自分自身で答えを見つけられるような、オープンな問いを投げかけてください
       - 質問は一つだけ、JSON形式で返してください
      PROMPT
    end

    private

    def format_daily_notes(daily_notes)
      result = []
      # daily noteを1日ずつ日付でラベルした文章に直していく。
      daily_notes.each do |daily_note|
        sentences = []
        if daily_note.did_today.present?
          sentences << "今日は「#{daily_note.did_today}」をしました。"
        end
        if daily_note.good_things.present?
          sentences << "その結果、「#{daily_note.good_things}」と感じました。"
        end
        if daily_note.challenge.present?
          sentences << "「#{daily_note.challenge}」はうまくいかなかったです。"
        end
        if daily_note.try_tomorrow.present?
          sentences << "明日は「#{daily_note.try_tomorrow}」をやりたいと思っています。"
        end
        if daily_note.memo.present?
          sentences << "今日は他には「#{daily_note.memo}」ということもありました。"
        end

        next if sentences.empty?
        date_label = daily_note.created_at.strftime("%m/%d")
        sentences.unshift("【#{date_label}】")

        result << sentences.join("\n")
      end

      result
    end
  end
end
