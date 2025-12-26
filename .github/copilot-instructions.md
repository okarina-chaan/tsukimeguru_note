## コードベースの概要（短く、要点）

- フレームワーク: Ruby on Rails 8 ベースのモノリポジトリ。
- フロントエンド: Tailwind CSS（`tailwindcss-rails`） + JavaScript（esbuild 経由）。React と Stimulus が共存。
- データ層: 本番は PostgreSQL（`pg`）、開発/テストに `sqlite3` が使われている構成が見られます（詳細は `config/database.yml` を確認）。
- 主要ディレクトリ: `app/controllers`, `app/models`, `app/views`, `app/services`（`config/application.rb` で autoload される）

## すぐ役立つ開発ワークフロー（コマンド）

- 依存を入れる: `bundle install` と `yarn install`
- 開発サーバ（単純）: `bin/rails server -b 0.0.0.0 -p 3000`
- Procfile.dev に示された dev プロセス（並列で起動する場合）:
  - `web`: `bin/rails server -b 0.0.0.0 -p ${PORT:-3000}`
  - `css`: `bin/rails tailwindcss:watch` (Tailwind の自動ビルド)
  - `js`: `yarn build --watch`（`package.json` の `build` スクリプト。開発では `build:watch` を使う）
- アセット（手動）: `yarn build`（`app/javascript` → `app/assets/builds`）
- DB 初期化（環境に応じて）: `bin/rails db:setup`（ローカルは sqlite3、検証後に production 用に `pg` を使う）
- テスト: `bundle exec rspec`（RSpec + Capybara が使われています）

## このリポジトリ特有のパターン・注意点

- generator 設定:
  - `config.generators` で `g.skip_routes true`, `g.helper false`, `g.test_framework nil` が設定されています。つまり自動生成された helper / test の追加が抑制されるので、生成後の手動ケアが必要です（テストやルーティングの追記を忘れないこと）。
- サービス層:
  - `app/services` を明示的にオートロードする設計です。APIやドメインロジックはここに集約されていることが多い（例: `app/services/moon_api_service.rb`, `app/services/moon_note_theme_service.rb`）。
- 外部連携:
  - LINE ログイン/通知: `omniauth-line`, `line_login_api_controller.rb` を使った実装があるため、LINE のクレデンシャル周りを変更する場合は `credentials` と関連環境変数を確認してください。
- 非同期 / キュー:
  - `solid_queue` 等の gem が含まれており、ActiveJob のキュー実装に依存する箇所がある可能性があります。実行環境（Sidekiq 等）をプロジェクト固有に合わせて確認してください。

## 変更箇所を編集する際の具体的ヒント（ファイル単位）

- ビュー修正: `app/views/*` の partial は Rails の慣習どおり。`analysis` 関連は `app/controllers/analysis_controller.rb` と `app/views/analysis/` にまとまっています。例: `insights` は `config/routes.rb` で `resource :analysis, path: "insights"` にマッピングされ、`weekly_insight` は collection の POST です（AJAX エンドポイントとして扱われることが多い）。
- サービス追加: 新たなビジネスロジックは `app/services/` に追加してください。`config/application.rb` によりオートロードされます。
- JS/フロント修正: `app/javascript` 配下を編集後は `yarn build`（本番向け）もしくは `yarn build:watch`（開発）でビルド結果が `app/assets/builds` に出力されます。esbuild を使用しており、`package.json` の `build` スクリプトがエントリです。

## コードレビューや PR に有用なチェックポイント（簡潔）

- 新しい gem を追加する場合、`Gemfile` と `bundle install` 後に起動確認（`bin/rails server`）を必ず行う。
- フロント側で新しいアセットを追加したら、`yarn build` を実行して `app/assets/builds` の出力を確認する。views がビルド済みアセットを参照しているかチェック。
- 認証や外部APIキー（LINE 等）を扱う変更では `config/credentials.yml.enc` や `.env` の扱いに注意。公開情報をコミットしないこと。

## 参考ファイル（開始点）

- アーキテクチャ／起動: `README.md`, `Procfile.dev`, `Rakefile`
- 依存: `Gemfile`, `package.json`
- ルーティング: `config/routes.rb`（`insights`/`analysis` の対応関係を参照）
- サービス層: `app/services/`（例: `moon_api_service.rb`）
- コントローラ/ビュー例: `app/controllers/analysis_controller.rb`, `app/views/analysis/_weekly_insight.html.erb`

---

もしこの案に追加して欲しい「よくあるタスク」や、より詳しく書いてほしいセクション（例: CI, デプロイ手順, ローカル environment の再現手順）があれば教えてください。次はその点を追記して再コミットします。

## 前提条件
- 回答は日本語で行うこと
- 変更前に確認すること
- 大規模な変更の場合、影響範囲を考慮し、変更計画を提案すること

## アプリの概要
- 月めぐるノートは月の満ち欠けと連動した日記アプリです。ユーザーは毎日の日記であるDaily Noteと、満月・新月・上弦の月・下弦の月に合わせたMoon Noteを記録できます。これによって、ユーザーは月のサイクルに合わせて自分の目標を設定したり、振り返ったりすることができます。
- 主要機能として、LINEログイン、月のフェーズに基づくテーマ設定、週次の振り返り分析、月のサイクルを反映させたカレンダー表示などがあります。