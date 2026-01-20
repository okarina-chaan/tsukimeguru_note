require "net/http"
require "json"

class MoonSignsController < ApplicationController
  before_action :require_login
  skip_before_action :require_login, only: [ :show ]

  def new
  end

  def create
    # フォームから生年月日・出生時刻・出生地（都道府県）を取得
    birth_date = params[:birth_date]
    birth_time = params[:birth_time].presence || "00:00"
    prefecture = params[:prefecture]

    # 都道府県名から緯度・経度を取得
    lat, lon = prefecture_to_coords(prefecture)

    # 日時を年・月・日・時・分に分解
    year, month, day = birth_date.split("-").map(&:to_i)
    hour, min = birth_time.split(":").map(&:to_i)
    sec = 0

    # 占星術API（Free Astrology API）へのリクエストを準備
    uri = URI("https://json.freeastrologyapi.com/western/planets")

    req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
    req["x-api-key"] = ENV["FREE_ASTROLOGY_API_KEY"]

    # APIリクエストボディを構築
    # 出生日時・場所・タイムゾーンを指定し、西洋占星術（tropical）の惑星位置を取得
    req.body = {
      year: year,
      month: month,
      date: day,
      hours: hour,
      minutes: min,
      seconds: sec,
      latitude: lat,
      longitude: lon,
      timezone: 9.0, # JST固定
      config: {
        observation_point: "topocentric",
        ayanamsha: "tropical",
        language: "en"
      }
    }.to_json

    # APIリクエストを送信し、レスポンスを取得
    begin
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
      Rails.logger.info("API response status: #{res.code}")
      Rails.logger.info("API response body: #{res.body}")
      data = JSON.parse(res.body)
    rescue => e
      # API通信エラー時はログに記録し、空のデータで続行
      Rails.logger.error("API通信エラー: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      data = {}
    end

    # APIレスポンスから月（Moon）のデータを抽出
    moon_data = data.dig("output")&.find { |p| p.dig("planet", "en") == "Moon" }

    # 月星座を判定し、日本語に変換
    if moon_data
      sign_en = moon_data.dig("zodiac_sign", "name", "en")
      @moon_sign = translate_sign(sign_en)
      @message = moon_sign_message(@moon_sign)
    else
      @moon_sign = "不明"
      @message = "月星座の情報が取得できませんでした。"
    end

    # X共有用のテキストとURLを生成
    text = "私の月星座は#{@moon_sign}でした🌙\n#{@message}\n#月めぐるノート で日記を書いてみよう"

    @share_url = "https://twitter.com/intent/tweet?text=#{ERB::Util.url_encode(text)}"
    @ogp_image_url = ogp_image_url(@moon_sign)

    # 結果ページにリダイレクトし、ユーザーの月星座を保存
    redirect_to "/moon_sign/#{sign_en.downcase}"
    current_user.update(moon_sign: @moon_sign)
  end

  def show
    # パラメータ無しでアクセスされた場合
    if params[:sign].blank?
      # ログイン済みなら、診断ページへ
      if current_user
        redirect_to new_moon_sign_path, alert: "まずは月星座診断してください。"
      # ログインしていないときは、トップページへ
      else
        redirect_to root_path, alert: "ログインしてください"
      end
      return
    end

    # 英語の星座名を取得して、URL用に小文字に直す
    english_sign = params[:sign]
    @sign = english_sign.capitalize

    @moon_sign = translate_sign(@sign)

    # 月星座が診断されていないときは、トップページにリダイレクトする
    if @moon_sign == "不明"
      redirect_to root_path, alert: "無効な星座名です。"
      return
    end

    @message = moon_sign_message(@moon_sign)
    @recommendations = DiaryRecommendations::LIST[@moon_sign]
    @ogp_image_url = ogp_image_url(@moon_sign)

    text = "私の月星座は#{@moon_sign}でした🌙\n#{@message}\n#月めぐるノート"
    page_url = "#{request.base_url}/moon_sign/#{params[:sign]}"
    @share_url = "https://x.com/intent/tweet?text=#{ERB::Util.url_encode(text)}&url=#{ERB::Util.url_encode(page_url)}"
  end

  private

  def prefecture_to_coords(prefecture)
    # 各県の県庁所在地の緯度・経度のリスト
    coords = {
      "北海道" => [ 43.0642, 141.3469 ],
      "青森県" => [ 40.8244, 140.7400 ],
      "岩手県" => [ 39.7036, 141.1527 ],
      "宮城県" => [ 38.2688, 140.8721 ],
      "秋田県" => [ 39.7186, 140.1024 ],
      "山形県" => [ 38.2404, 140.3633 ],
      "福島県" => [ 37.7500, 140.4678 ],
      "茨城県" => [ 36.3418, 140.4468 ],
      "栃木県" => [ 36.5657, 139.8836 ],
      "群馬県" => [ 36.3911, 139.0608 ],
      "埼玉県" => [ 35.8569, 139.6489 ],
      "千葉県" => [ 35.6050, 140.1233 ],
      "東京都" => [ 35.6895, 139.6917 ],
      "神奈川県" => [ 35.4478, 139.6425 ],
      "新潟県" => [ 37.9026, 139.0236 ],
      "富山県" => [ 36.6953, 137.2114 ],
      "石川県" => [ 36.5947, 136.6256 ],
      "福井県" => [ 36.0652, 136.2216 ],
      "山梨県" => [ 35.6642, 138.5684 ],
      "長野県" => [ 36.6513, 138.1810 ],
      "岐阜県" => [ 35.3912, 136.7223 ],
      "静岡県" => [ 34.9769, 138.3831 ],
      "愛知県" => [ 35.1802, 136.9066 ],
      "三重県" => [ 34.7303, 136.5086 ],
      "滋賀県" => [ 35.0045, 135.8686 ],
      "京都府" => [ 35.0214, 135.7556 ],
      "大阪府" => [ 34.6937, 135.5023 ],
      "兵庫県" => [ 34.6913, 135.1830 ],
      "奈良県" => [ 34.6851, 135.8329 ],
      "和歌山県" => [ 34.2260, 135.1675 ],
      "鳥取県" => [ 35.5039, 134.2381 ],
      "島根県" => [ 35.4723, 133.0505 ],
      "岡山県" => [ 34.6618, 133.9344 ],
      "広島県" => [ 34.3966, 132.4596 ],
      "山口県" => [ 34.1859, 131.4714 ],
      "徳島県" => [ 34.0658, 134.5593 ],
      "香川県" => [ 34.3401, 134.0434 ],
      "愛媛県" => [ 33.8416, 132.7657 ],
      "高知県" => [ 33.5597, 133.5311 ],
      "福岡県" => [ 33.5902, 130.4017 ],
      "佐賀県" => [ 33.2494, 130.2988 ],
      "長崎県" => [ 32.7448, 129.8737 ],
      "熊本県" => [ 32.7898, 130.7417 ],
      "大分県" => [ 33.2382, 131.6126 ],
      "宮崎県" => [ 31.9111, 131.4239 ],
      "鹿児島県" => [ 31.5602, 130.5581 ],
      "沖縄県" => [ 26.2124, 127.6809 ]
    }
    coords[prefecture] || [ 35.6895, 139.6917 ]
  end

  def translate_sign(sign)
    {
      "Aries" => "牡羊座", "Taurus" => "牡牛座", "Gemini" => "双子座",
      "Cancer" => "蟹座", "Leo" => "獅子座", "Virgo" => "乙女座",
      "Libra" => "天秤座", "Scorpio" => "蠍座", "Sagittarius" => "射手座",
      "Capricorn" => "山羊座", "Aquarius" => "水瓶座", "Pisces" => "魚座"
    }[sign] || "不明"
  end

  def moon_sign_message(sign)
    {
      "牡羊座" => "情熱的で直感に従うタイプ。",
      "牡牛座" => "穏やかで五感を大切にする人。",
      "双子座" => "好奇心旺盛で話し好き。",
      "蟹座" => "家族思いで優しい心の持ち主。",
      "獅子座" => "自信にあふれ、自己表現が得意。",
      "乙女座" => "几帳面で人の役に立つことが好き。",
      "天秤座" => "バランス感覚に優れた平和主義者。",
      "蠍座" => "情が深く、一途な愛情の持ち主。",
      "射手座" => "自由を愛し、探求心にあふれる。",
      "山羊座" => "責任感が強く、コツコツ努力型。",
      "水瓶座" => "独創的で常識にとらわれない。",
      "魚座" => "感受性豊かで思いやりのある人。"
    }[sign] || "あなたの感性が月に導かれています。"
  end

  def ogp_image_url(sign)
    valid_signs = %w[牡羊座 牡牛座 双子座 蟹座 獅子座 乙女座 天秤座 蠍座 射手座 山羊座 水瓶座 魚座]
    return nil unless valid_signs.include?(sign)

    "#{request.base_url}/ogp/#{ERB::Util.url_encode(sign)}.png"
  end
end
