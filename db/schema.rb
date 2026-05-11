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

ActiveRecord::Schema[8.1].define(version: 2026_05_09_133251) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "account_balances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.decimal "current_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "last_entry_at"
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_balances_on_account_id"
    t.index ["organization_id", "account_id"], name: "index_account_balances_on_organization_id_and_account_id", unique: true
    t.index ["organization_id"], name: "index_account_balances_on_organization_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "account_type", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.uuid "parent_id"
    t.datetime "updated_at", null: false
    t.index ["organization_id", "code"], name: "index_accounts_on_organization_id_and_code", unique: true
    t.index ["organization_id"], name: "index_accounts_on_organization_id"
    t.index ["parent_id"], name: "index_accounts_on_parent_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "entry_date", null: false
    t.boolean "is_locked", default: false, null: false
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id", "entry_date"], name: "index_journal_entries_on_organization_id_and_entry_date"
    t.index ["organization_id"], name: "index_journal_entries_on_organization_id"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "journal_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.decimal "credit", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "debit", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "journal_entry_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_journal_items_on_account_id"
    t.index ["journal_entry_id"], name: "index_journal_items_on_journal_entry_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "base_currency", default: "INR", null: false
    t.datetime "created_at", null: false
    t.date "fiscal_year_start"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "organization_id", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 3, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "account_balances", "accounts"
  add_foreign_key "account_balances", "organizations"
  add_foreign_key "accounts", "accounts", column: "parent_id"
  add_foreign_key "accounts", "organizations"
  add_foreign_key "journal_entries", "organizations"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "journal_items", "accounts"
  add_foreign_key "journal_items", "journal_entries"
  add_foreign_key "users", "organizations"
end
