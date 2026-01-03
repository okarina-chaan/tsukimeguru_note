module Reflection
  class OpenAiService < BaseService
    API_URL = "https://api.openai.com/v1/chat/completions".freeze

    def initialize(daily_notes:)
      @daily_notes = daily_notes
      @api_key = ENV["OPENAI_API_KEY"]
      @client = build_client
    end

    def call
      raise StandardError, "OpenAI API key not found" if @api_key.blank?

      formatted_notes = format_daily_notes(@daily_notes)
      return { error: "日記データがありません" } if formatted_notes.empty?

      request_body = build_request_body(formatted_notes)

      begin
        response = @client.post(API_URL, request_body.to_json, headers)
        parse_response(response)
      rescue => e
        handle_error(e)
      end
    end

    private

    def build_client
      Faraday.new do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end

    def headers
      {
        "Authorization" => "Bearer #{@api_key}",
        "Content-Type" => "application/json"
      }
    end

    def build_request_body(formatted_notes)
      prompt = build_prompt(formatted_notes)

      {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "user",

            content: prompt
          }
        ],
        max_tokens: 500,
        temperature: 0.7
      }
    end

    def build_prompt(formatted_notes)
      <<-PROMPT
      あなたはユーザーが先週1週間で書いた日記を読んで、書き手自身が深く振り返るための「問い」を投げかける役割です。
      まずは先週の日記の要約を事実データから客観的に返してください。
      次に、評価や助言は一切せず、書き手が自分で考えを深められるような質問を1つ提示してください。

      # 日記の内容
      これらは事実データです。解釈することは禁止します。
      #{formatted_notes.join("\n\n")}

      # 出力
      {
        "summary": "...",
        "question": "...?"
      }

      # 重要な制約
      - 日記の内容を評価したり、アドバイスしたりしないでください
      - 「良い」「悪い」などの価値判断を含めないでください
      - 書き手が自分自身で答えを見つけられるような、オープンな問いを投げかけてください
      - 質問は一つだけ、JSON形式で返してください
      - 要約と質問はそれぞれ一つの文章で返してください
      PROMPT
    end

    def parse_response(response)
      if response.status == 200 && response.body["choices"]&.any?
        content = response.body["choices"][0]["message"]["content"]
        JSON.parse(content)
      else
        { error: "OpenAI APIからの応答が不正です" }
      end
    rescue JSON::ParserError
      { error: "レスポンスの解析に失敗しました" }
    end

    def handle_error(error)
      case error
      when Faraday::TimeoutError
        { error: "API呼び出しがタイムアウトしました" }
      when Faraday::ConnectionFailed
        { error: "OpenAI APIへの接続に失敗しました" }
      when Faraday::UnauthorizedError
        { error: "OpenAI API認証に失敗しました" }
      else
        { error: "予期しないエラーが発生しました: #{error.message}" }
      end
    end

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
