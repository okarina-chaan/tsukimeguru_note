class AddMoonSignToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :moon_sign, :string
  end
end
