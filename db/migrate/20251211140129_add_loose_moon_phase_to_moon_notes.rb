class AddLooseMoonPhaseToMoonNotes < ActiveRecord::Migration[8.0]
  def up
    add_column :moon_notes, :loose_moon_phase, :integer

    execute <<~SQL.squish
      UPDATE moon_notes
      SET loose_moon_phase = moon_phase
    SQL
  end

  def down
    remove_column :moon_notes, :loose_moon_phase
  end
end
