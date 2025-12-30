class WeeklySummaryPresenter
  def initialize(user, at: Time.zone.today)
    @user = user
    @start_date = (at - 1.week).beginning_of_week
    @end_date   = (at - 1.week).end_of_week
  end

  def notes
    @notes ||= @user.daily_notes.where(date: @start_date..@end_date)
  end

  def count
    notes.count
  end

  def avg_condition
    notes.average(:condition_score)&.round(1)
  end

  def avg_mood
    notes.average(:mood_score)&.round(1)
  end

  def any?
    count.positive?
  end
end
