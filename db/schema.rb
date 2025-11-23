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

ActiveRecord::Schema[8.0].define(version: 2025_11_23_024655) do
  create_table "daily_notes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "date", null: false
    t.integer "condition_score"
    t.integer "mood_score"
    t.text "did_today"
    t.string "challenge"
    t.string "good_things"
    t.string "try_tomorrow"
    t.text "memo"
    t.string "moon_phase_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "moon_phase_emoji"
    t.index ["user_id", "date"], name: "index_daily_notes_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_daily_notes_on_user_id"
  end

  create_table "moon_notes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "date", null: false
    t.float "moon_age", null: false
    t.integer "moon_phase", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "date"], name: "index_moon_notes_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_moon_notes_on_user_id"
  end

  create_table "prefectures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "line_user_id", null: false
    t.string "name"
    t.boolean "account_registered", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "moon_sign"
    t.index ["line_user_id"], name: "index_users_on_line_user_id", unique: true
  end

  add_foreign_key "daily_notes", "users"
  add_foreign_key "moon_notes", "users"
end
