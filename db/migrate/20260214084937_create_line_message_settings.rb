class CreateLineMessageSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :line_message_settings do |t|
      t.references :user, null: false, foreign_key: true

      t.boolean :new_moon, default: false, null: false
      t.boolean :first_quarter_moon, default: false, null: false
      t.boolean :full_moon, default: false, null: false
      t.boolean :last_quarter_moon, default: false, null: false

      t.datetime :last_notified_at

      t.timestamps
    end
  end
end
