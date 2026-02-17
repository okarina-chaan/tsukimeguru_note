# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_14_084937) do
  create_table "authentications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["provider", "uid"], name: "index_authentications_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "daily_notes", force: :cascade do |t|
    t.string "challenge"
    t.integer "condition_score"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "did_today"
    t.string "good_things"
    t.text "memo"
    t.integer "mood_score"
    t.string "moon_phase_emoji"
    t.string "moon_phase_name"
    t.string "try_tomorrow"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "date"], name: "index_daily_notes_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_daily_notes_on_user_id"
  end

  create_table "line_message_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "first_quarter_moon", default: false, null: false
    t.boolean "full_moon", default: false, null: false
    t.datetime "last_notified_at"
    t.boolean "last_quarter_moon", default: false, null: false
    t.boolean "new_moon", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_line_message_settings_on_user_id"
  end

  create_table "moon_notes", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "loose_moon_phase"
    t.float "moon_age", null: false
    t.integer "moon_phase", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "date"], name: "index_moon_notes_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_moon_notes_on_user_id"
  end

  create_table "moon_phases", force: :cascade do |t|
    t.float "angle"
    t.datetime "created_at", null: false
    t.date "date"
    t.float "moon_age"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_moon_phases_on_date", unique: true
  end

  create_table "prefectures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "account_registered", default: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "line_user_id"
    t.string "moon_sign"
    t.string "name"
    t.datetime "updated_at", null: false
    t.datetime "weekly_insight_generated_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "email IS NOT NULL"
    t.index ["line_user_id"], name: "index_users_on_line_user_id", unique: true
  end

  add_foreign_key "authentications", "users"
  add_foreign_key "daily_notes", "users"
  add_foreign_key "line_message_settings", "users"
  add_foreign_key "moon_notes", "users"
end
