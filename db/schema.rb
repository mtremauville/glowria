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

ActiveRecord::Schema[8.1].define(version: 2026_04_12_195435) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text "content"
    t.jsonb "context", default: {}
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "conflict_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ingredient_a_id", null: false
    t.bigint "ingredient_b_id", null: false
    t.string "message"
    t.string "recommendation"
    t.string "severity"
    t.datetime "updated_at", null: false
    t.index ["ingredient_a_id"], name: "index_conflict_rules_on_ingredient_a_id"
    t.index ["ingredient_b_id"], name: "index_conflict_rules_on_ingredient_b_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.text "benefits"
    t.text "concerns"
    t.datetime "created_at", null: false
    t.string "function"
    t.string "inci_name"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "product_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.integer "position"
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_product_ingredients_on_ingredient_id"
    t.index ["product_id"], name: "index_product_ingredients_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "barcode"
    t.string "brand"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.string "shop_url"
    t.datetime "updated_at", null: false
  end

  create_table "routine_steps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "instruction"
    t.integer "order"
    t.bigint "routine_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_product_id", null: false
    t.index ["routine_id"], name: "index_routine_steps_on_routine_id"
    t.index ["user_product_id"], name: "index_routine_steps_on_user_product_id"
  end

  create_table "routines", force: :cascade do |t|
    t.text "ai_summary"
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.string "name"
    t.string "period"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_routines_on_user_id"
  end

  create_table "user_products", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.string "usage_slot"
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_user_products_on_product_id"
    t.index ["user_id"], name: "index_user_products_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.text "skin_concerns"
    t.text "skin_goals"
    t.string "skin_type"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "conflict_rules", "ingredients", column: "ingredient_a_id"
  add_foreign_key "conflict_rules", "ingredients", column: "ingredient_b_id"
  add_foreign_key "product_ingredients", "ingredients"
  add_foreign_key "product_ingredients", "products"
  add_foreign_key "routine_steps", "routines"
  add_foreign_key "routine_steps", "user_products"
  add_foreign_key "routines", "users"
  add_foreign_key "user_products", "products"
  add_foreign_key "user_products", "users"
end
