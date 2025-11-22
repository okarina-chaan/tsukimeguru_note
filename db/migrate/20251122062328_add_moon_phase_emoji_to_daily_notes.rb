class AddMoonPhaseEmojiToDailyNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :daily_notes, :moon_phase_emoji, :string
  end
end
