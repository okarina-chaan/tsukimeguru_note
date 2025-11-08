class CreateDailyNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_notes do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :condition_score
      t.integer :mood_score
      t.text :did_today
      t.string :challenge
      t.string :good_things
      t.string :try_tomorrow
      t.text :memo
      t.string :moon_phase_name

      t.timestamps
    end

    add_index :daily_notes, [ :user_id, :date ], unique: true
  end
end
