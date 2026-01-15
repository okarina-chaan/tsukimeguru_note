class MigrateToMultiProviderAuthentication < ActiveRecord::Migration[8.0]
  def up
    puts "Starting migration of LINE users to authentications table..."

    # emailカラムを追加
    add_column :users, :email, :string

    # line_user_idをnullable化（新しいメール認証ユーザー用）
    change_column_null :users, :line_user_id, true

    # 条件付きユニークインデックス（nullは除外）
    add_index :users, :email, unique: true, where: "email IS NOT NULL"

    # 既存ユーザーのLINE認証データを移行（直接SQLを使用）
    execute <<-SQL
      INSERT INTO authentications (user_id, provider, uid, created_at, updated_at)
      SELECT id, 'line', line_user_id, NOW(), NOW()
      FROM users
      WHERE line_user_id IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM authentications
        WHERE authentications.user_id = users.id
        AND authentications.provider = 'line'
      )
    SQL

    migrated_count = select_value("SELECT COUNT(*) FROM authentications WHERE provider = 'line'")
    puts "Migration completed: #{migrated_count} LINE authentications created"
  end

  def down
    remove_index :users, :email, where: "email IS NOT NULL"
    remove_column :users, :email
    change_column_null :users, :line_user_id, false

    count = select_value("SELECT COUNT(*) FROM authentications WHERE provider = 'line'")
    execute "DELETE FROM authentications WHERE provider = 'line'"
    puts "Rolled back: removed #{count} LINE authentications"
  end
end
