class AddDestroyTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :destroy_token, :string
    add_column :users, :destroy_token_expires_at, :datetime

    add_index :users, :destroy_token, unique: true
  end
end
