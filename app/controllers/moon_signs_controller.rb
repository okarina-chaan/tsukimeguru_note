require "net/http"
require "json"

class MoonSignsController < ApplicationController
  def new
  end

  def create
    birth_date = params[:birth_date]
    birth_time = params[:birth_time].presence || "00:00"
    prefecture = params[:prefecture]

    lat, lon = prefecture_to_coords(prefecture)

    year, month, day = birth_date.split("-").map(&:to_i)
    hour, min = birth_time.split(":").map(&:to_i)
    sec = 0

    uri = URI("https://json.freeastrologyapi.com/western/planets")

    req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
    req["x-api-key"] = ENV["FREE_ASTROLOGY_API_KEY"]

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

  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    Rails.logger.info("API response status: #{res.code}")
    Rails.logger.info("API response body: #{res.body}")
    data = JSON.parse(res.body)
  rescue => e
    Rails.logger.error("API通信エラー: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    data = {}
  end

    moon_data = data.dig("output")&.find { |p| p.dig("planet", "en") == "Moon" }

    if moon_data
      sign_en = moon_data.dig("zodiac_sign", "name", "en")
      @moon_sign = translate_sign(sign_en)
      @message = moon_sign_message(@moon_sign)
    else
      @moon_sign = "不明"
      @message = "月星座の情報が取得できませんでした。"
    end

    text = "私の月星座は#{@moon_sign}でした🌙\n#{@message}\n#月めぐるノート で日記を書いてみよう"

    @share_url = "https://twitter.com/intent/tweet?text=#{ERB::Util.url_encode(text)}"

    render :show
    current_user.update(moon_sign: @moon_sign)
  end

  def show
    @moon_sign ||= current_user.moon_sign
    if @moon_sign.blank?
      redirect_to new_moon_sign_path, alert: "まずは月星座を診断してください。"
      return
    end

    @message = moon_sign_message(@moon_sign)
    @recommendations = DialyRecommendations::LIST[@moon_sign]
  end

  private

  def prefecture_to_coords(prefecture)
    coords = {
      "東京都" => [ 35.6895, 139.6917 ],
      "大阪府" => [ 34.6937, 135.5023 ],
      "福岡県" => [ 33.5902, 130.4017 ],
      "北海道" => [ 43.0642, 141.3469 ],
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
end
