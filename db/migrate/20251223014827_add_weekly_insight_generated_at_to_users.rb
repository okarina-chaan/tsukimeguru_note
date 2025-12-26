class AddWeeklyInsightGeneratedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :weekly_insight_generated_at, :datetime
  end
end
