class CreateMoonNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :moon_notes do |t|
      t.references :user, null: false, foreign_key: true

      t.date :date, null: false
      t.float :moon_age, null: false
      t.integer :moon_phase, null: false
      t.text :content

      t.timestamps
    end

    add_index :moon_notes, [ :user_id, :date ], unique: true
  end
end
