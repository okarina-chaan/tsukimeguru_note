case Rails.env
when "development"
  load Rails.root.join("db/seeds/development.rb")
when "production"
  # 開発環境で使用するときはコメントアウトして使う
  # load Rails.root.join("db/seeds/production.rb")
else
  puts "No seeds for this environment"
end
