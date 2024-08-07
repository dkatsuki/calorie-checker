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

ActiveRecord::Schema[7.0].define(version: 2023_11_17_121510) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dish_articles", force: :cascade do |t|
    t.bigint "dish_id"
    t.json "headers"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_dish_articles_on_dish_id"
  end

  create_table "dishes", force: :cascade do |t|
    t.string "name", null: false
    t.string "ruby", null: false
    t.integer "genre", default: 0, null: false
    t.string "main_image_key"
    t.string "unit", null: false
    t.float "calorie", null: false
    t.float "carbohydrate", null: false
    t.float "fat", null: false
    t.float "protein", null: false
    t.float "sugar", null: false
    t.boolean "is_open", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "foodstuffs", force: :cascade do |t|
    t.string "name", null: false
    t.string "ruby", null: false
    t.integer "category", default: 0, null: false
    t.boolean "is_pure", default: true, null: false
    t.json "unit_list", default: {}, null: false
    t.string "main_image_key"
    t.float "calorie", null: false
    t.float "carbohydrate", null: false
    t.float "fat", null: false
    t.float "protein", null: false
    t.float "sugar", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "foodstuff_id"
    t.bigint "dish_id"
    t.float "gram_weight"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_recipes_on_dish_id"
    t.index ["foodstuff_id"], name: "index_recipes_on_foodstuff_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "approved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_staffs_on_email", unique: true
    t.index ["reset_password_token"], name: "index_staffs_on_reset_password_token", unique: true
  end

  add_foreign_key "dish_articles", "dishes"
  add_foreign_key "recipes", "dishes"
  add_foreign_key "recipes", "foodstuffs"
end
