class MigrateToMultiProviderAuthentication < ActiveRecord::Migration[8.0]
  def up
    puts "Starting migration of LINE users to authentications table..."
    migrated_count = 0
    skipped_count = 0

    # emailカラムを追加
    add_column :users, :email, :string

    # Userモデルをリロードする
    User.reset_column_information

    # 既存ユーザーのLINE認証データを移行
    User.where.not(line_user_id: nil).find_each do |user|
      # 既に存在する場合はスキップ
      if user.authentications.exists?(provider: 'line')
        puts "  Skipping user #{user.id} - already migrated"
        skipped_count += 1
        next
      end

      user.authentications.create!(
        provider: 'line',
        uid: user.line_user_id
      )
      puts "  ✓ Migrated user #{user.id}"
      migrated_count += 1
    end

    puts "Migration completed: #{migrated_count} migrated, #{skipped_count} skipped"

    # line_user_idをnullable化（新しいメール認証ユーザー用）
    change_column_null :users, :line_user_id, true

    # 条件付きユニークインデックス（nullは除外）
    add_index :users, :email, unique: true, where: "email IS NOT NULL"
  end

  def down
    remove_index :users, :email, where: "email IS NOT NULL"
    remove_column :users, :email
    change_column_null :users, :line_user_id, false

    count = Authentication.where(provider: 'line').count
    Authentication.where(provider: 'line').destroy_all
    puts "Rolled back: removed #{count} LINE authentications"
  end
end
