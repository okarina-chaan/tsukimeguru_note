class CreateAuthentications < ActiveRecord::Migration[8.0]
  def change
    create_table :authentications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :password_digest

      t.timestamps

      t.index [ :provider, :uid ], unique: true
    end
  end
end
