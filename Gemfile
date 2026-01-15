source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire"s SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-ruby"
gem "tailwindcss-rails", "~> 4.3"

gem "heroicon"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# 認証に使った
gem "omniauth-auth0"

# CSRF対策
gem "omniauth-rails_csrf_protection"

# HTTP通信に使う
gem "faraday"

# i18n
gem "rails-i18n"

# 静的なページを作る
gem "high_voltage"

# ページネーション
gem "kaminari", git: "https://github.com/kaminari/kaminari"

# 月相を一括で保存することに使う
gem "activerecord-import"

group :development, :production do
  # Lineログイン
  gem "omniauth-line"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 7.1.2"

  gem "sqlite3", "~> 2.9"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # ダミーデータ作成
  gem "faker"

  # .envファイルの読み込み
  gem "dotenv-rails"

  # テスト関連
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "capybara"
  gem "selenium-webdriver", "= 4.38.0"

  gem "pry-rails"

  # stubを効率的に（openAI APIの挙動確認で入れた）
  gem "stub_env", "~> 1.0", ">= 1.0.4"

  # 冗長なクエリを検索
  gem "bullet"
end

group :development do
  # デバッグを楽に
  gem "better_errors"
  gem "binding_of_caller"


  # パフォーマンス計測
  gem "rack-mini-profiler", require: false

  # メモリの計測
  gem "memory_profiler"

  # 計測結果をグラフ表示させる
  gem "stackprof"
  gem "flamegraph"
end

group :test do
  gem "webmock"
  gem "rack_session_access", "~> 0.2.0"
  gem "database_cleaner-active_record"
end
