class CreatePrefectures < ActiveRecord::Migration[8.0]
  def change
    create_table :prefectures do |t|
      t.timestamps
    end
  end
end
