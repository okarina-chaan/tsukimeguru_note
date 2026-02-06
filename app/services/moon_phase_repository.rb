class MoonPhaseRepository
  # 指定した月の月相データを取得（なければAPIから取得して保存）
  def self.fetch_month(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    # DBに全データがあるか確認
    existing_dates = MoonPhase.where(date: start_date..end_date).pluck(:date)

    if existing_dates.size == (end_date - start_date + 1).to_i
      # 全データあり：DBから返す
      Rails.logger.info("月相データをDBから取得: #{year}年#{month}月")
      return MoonPhase.where(date: start_date..end_date).order(:date)
    end

    # 不足データあり：APIから取得して保存
    Rails.logger.info("月相データをAPIから取得: #{year}年#{month}月")
    fetch_and_save_month(start_date, end_date)
  end

  # 指定した日の月相データを取得（なければAPIから取得して保存）
  def self.fetch_date(date)
    moon_phase = MoonPhase.find_by(date: date)
    return moon_phase if moon_phase.present?

    # APIから取得して保存
    Rails.logger.info("月相データをAPIから取得: #{date}")
    data = MoonApiService.fetch(date)
    return nil if data.nil?
    return nil if data[:angle].nil? || data[:moon_age].nil?

    MoonPhase.create!(
      date: date,
      angle: data[:angle],
      moon_age: data[:moon_age]
    )
  end

  private

  def self.fetch_and_save_month(start_date, end_date)
    moon_phases = []

    (start_date..end_date).each do |date|
      next if MoonPhase.exists?(date: date)

      data = MoonApiService.fetch(date)
      next if data.nil?
      next if data[:angle].nil? || data[:moon_age].nil?

      moon_phases << MoonPhase.new(
        date: date,
        angle: data[:angle],
        moon_age: data[:moon_age]
      )
    end

    # 一括保存
    MoonPhase.import(moon_phases) if moon_phases.any?

    # 保存後、全データを返す
    MoonPhase.where(date: start_date..end_date).order(:date)
  end
end
