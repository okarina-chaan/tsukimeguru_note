class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :line_user_id, null: false, index: { unique: true }
      t.string :name
      t.boolean :account_registered, default: false

      t.timestamps
    end
  end
end
