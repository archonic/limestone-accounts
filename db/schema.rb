# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_03_08_005357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", limit: 40, null: false
    t.integer "plan_id"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "card_last4", limit: 4
    t.integer "card_exp_month", limit: 2
    t.integer "card_exp_year"
    t.string "card_type"
    t.datetime "current_period_end"
    t.boolean "trialing", default: true, null: false
    t.boolean "past_due", default: false, null: false
    t.boolean "unpaid", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["cancelled"], name: "index_accounts_on_cancelled"
    t.index ["current_period_end"], name: "index_accounts_on_current_period_end"
    t.index ["name"], name: "index_accounts_on_name"
    t.index ["past_due"], name: "index_accounts_on_past_due"
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true
    t.index ["unpaid"], name: "index_accounts_on_unpaid"
    t.index ["discarded_at"], name: "index_accounts_on_discarded_at"
  end

  create_table "accounts_users", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "user_id", null: false
    t.index ["account_id", "user_id"], name: "index_accounts_users_on_account_id_and_user_id", unique: true
  end

  create_table "accounts_users_roles", id: false, force: :cascade do |t|
    t.bigint "accounts_user_id"
    t.bigint "role_id"
    t.index ["accounts_user_id", "role_id"], name: "index_accounts_users_roles_on_accounts_user_id_and_role_id"
    t.index ["accounts_user_id"], name: "index_accounts_users_roles_on_accounts_user_id"
    t.index ["role_id"], name: "index_accounts_users_roles_on_role_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "account_id"
    t.string "stripe_id"
    t.integer "amount"
    t.string "currency"
    t.string "number"
    t.datetime "paid_at"
    t.text "lines"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_id"], name: "index_invoices_on_stripe_id", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.integer "amount", null: false
    t.string "currency", null: false
    t.string "interval", null: false
    t.string "stripe_id"
    t.boolean "active", default: true, null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: true
    t.string "last_name", null: true
    t.string "full_name", null: true
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.boolean "super_admin", default: false, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
