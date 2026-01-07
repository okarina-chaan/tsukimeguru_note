class CreateMoonPhases < ActiveRecord::Migration[8.0]
  def change
    create_table :moon_phases do |t|
      t.date :date
      t.float :angle
      t.float :moon_age

      t.timestamps
    end

    add_index :moon_phases, :date, unique: true
  end
end
