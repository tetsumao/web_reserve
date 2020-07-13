# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_01_152335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "item_name"
    t.integer "stock"
    t.text "description"
    t.integer "dspo", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deleted_at"], name: "index_items_on_deleted_at"
  end

  create_table "linkages", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mng_reservations", force: :cascade do |t|
    t.string "user_name"
    t.bigint "item_id", null: false
    t.integer "number", default: 1, null: false
    t.string "reservation_name", default: "", null: false
    t.date "reservation_date", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.bigint "web_reservation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_mng_reservations_on_item_id"
    t.index ["web_reservation_id"], name: "index_mng_reservations_on_web_reservation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "user_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "web_reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.integer "number", default: 1, null: false
    t.string "reservation_name", default: "", null: false
    t.date "reservation_date", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_web_reservations_on_item_id"
    t.index ["user_id"], name: "index_web_reservations_on_user_id"
  end

  add_foreign_key "mng_reservations", "items"
  add_foreign_key "mng_reservations", "web_reservations"
  add_foreign_key "web_reservations", "items"
  add_foreign_key "web_reservations", "users"
end
