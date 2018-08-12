# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20180519005503) do

  create_table "agency_collections", force: :cascade do |t|
    t.string   "name",            limit: 255,                null: false
    t.string   "addr1",           limit: 255,                null: false
    t.string   "addr2",           limit: 255,                null: false
    t.string   "addr3",           limit: 255,                null: false
    t.string   "addr4",           limit: 255,                null: false
    t.string   "webpage",         limit: 255
    t.boolean  "active",                      default: true
    t.integer  "total_employees", limit: 4,   default: 0
    t.integer  "created_by",      limit: 4
    t.integer  "updated_by",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.string   "request_uuid",    limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "communities", force: :cascade do |t|
    t.string   "name",           limit: 255,                 null: false
    t.string   "addr1",          limit: 255,                 null: false
    t.string   "addr2",          limit: 255,                 null: false
    t.string   "addr3",          limit: 255,                 null: false
    t.string   "addr4",          limit: 255,                 null: false
    t.integer  "total_pics",     limit: 4,   default: 0
    t.float    "processing_fee", limit: 24,  default: 0.0
    t.boolean  "verified",                   default: false
    t.boolean  "active",                     default: true
    t.integer  "manager_id",     limit: 4
    t.integer  "created_by",     limit: 4
    t.integer  "updated_by",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "community_pics", force: :cascade do |t|
    t.integer  "community_id",         limit: 4,                   null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.string   "about_pic",            limit: 255,                 null: false
    t.boolean  "primary_pic",                      default: false
    t.integer  "created_by",           limit: 4
    t.integer  "updated_by",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "house_contract_notes", force: :cascade do |t|
    t.integer  "user_house_contract_id", limit: 4
    t.string   "note",                   limit: 1000
    t.boolean  "active"
    t.boolean  "private"
    t.integer  "created_by",             limit: 4
    t.integer  "updated_by",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "house_notes", force: :cascade do |t|
    t.integer  "house_id",   limit: 4,                    null: false
    t.string   "note",       limit: 1000
    t.boolean  "active",                  default: true
    t.integer  "created_by", limit: 4
    t.integer  "updated_by", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",                 default: false
  end

  create_table "house_pics", force: :cascade do |t|
    t.integer  "house_id",             limit: 4,                   null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.string   "rekognition_labels", limit: 1000
    t.string   "rekognition_text", limit: 2000
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
    t.string   "about_pic",            limit: 255,                 null: false
    t.boolean  "primary_pic",                      default: false
    t.integer  "created_by",           limit: 4
    t.integer  "updated_by",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "houses", force: :cascade do |t|
    t.string   "name",            limit: 255,                  null: false
    t.string   "addr1",           limit: 255,                  null: false
    t.string   "addr2",           limit: 255,                  null: false
    t.string   "addr3",           limit: 255,                  null: false
    t.string   "addr4",           limit: 255,                  null: false
    t.integer  "no_of_portions",  limit: 4,    default: 1
    t.integer  "no_of_floors",    limit: 4,    default: 1
    t.integer  "total_pics",      limit: 4,    default: 0
    t.float    "processing_fee",  limit: 24,   default: 0.0
    t.boolean  "verified",                     default: false
    t.boolean  "active",                       default: true
    t.integer  "community_id",    limit: 4
    t.integer  "created_by",      limit: 4
    t.integer  "updated_by",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",     limit: 1000
    t.boolean  "is_open",                      default: true
    t.integer  "no_of_bedrooms",  limit: 4,    default: 1
    t.integer  "no_of_bathrooms", limit: 4,    default: 1
    t.integer  "floor_number",    limit: 4,    default: 1
    t.string   "search",          limit: 2000
    t.integer  "account_id",      limit: 4
  end
  add_index "houses", ["search"], name: "search_index", using: :btree

  create_table "notification_types", force: :cascade do |t|
    t.integer  "ntype",           limit: 4,   default: 0
    t.string   "content",         limit: 255
    t.string   "subject",         limit: 255, default: "Notification from H4R"
    t.boolean  "require_retries",             default: false
    t.boolean  "active",                      default: true
    t.integer  "created_by",      limit: 4
    t.integer  "updated_by",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",              limit: 4,                null: false
    t.integer  "notification_type_id", limit: 4, default: 0
    t.integer  "retries_count",        limit: 4, default: 0
    t.boolean  "active",                         default: true
    t.integer  "priority",             limit: 4, default: 8
    t.integer  "created_by",           limit: 4
    t.integer  "updated_by",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "user_house_contract_id", limit: 4,                   null: false
    t.float    "amount",                 limit: 24,                  null: false
    t.integer  "payment_status",         limit: 4,    default: 0
    t.integer  "payment_type",           limit: 4,    default: 0
    t.integer  "retries_count",          limit: 4,    default: 0
    t.integer  "created_by",             limit: 4
    t.integer  "updated_by",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "note",                   limit: 1000
    t.datetime "payment_date"
    t.boolean  "active",                              default: true
  end
  
  create_table "accounts", force: :cascade do |t|
    t.float    "baseline_amt",       limit: 24,   default: 0
    t.datetime "baseline_date",      limit: 24,   default: 0
    t.integer  "created_by",         limit: 4
    t.integer  "updated_by",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "note",               limit: 1000
    t.boolean  "active",                          default: true
  end

  create_table "property_mgmts", force: :cascade do |t|
    t.string   "name",            limit: 255,                null: false
    t.string   "addr1",           limit: 255,                null: false
    t.string   "addr2",           limit: 255,                null: false
    t.string   "addr3",           limit: 255,                null: false
    t.string   "addr4",           limit: 255,                null: false
    t.string   "webpage",         limit: 255
    t.integer  "total_employees", limit: 4,   default: 0
    t.boolean  "active",                      default: true
    t.integer  "created_by",      limit: 4
    t.integer  "updated_by",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "ticket_notes", force: :cascade do |t|
    t.integer  "ticket_id",    limit: 4
    t.string   "note",         limit: 1000
    t.integer  "created_by",   limit: 4
    t.integer  "updated_by",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private_note",              default: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "subject",     limit: 500,  default: "N/A"
    t.string   "description", limit: 1000, default: "N/A"
    t.integer  "status",      limit: 4,    default: 1
    t.boolean  "active",                   default: true
    t.integer  "created_by",  limit: 4
    t.integer  "updated_by",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_agency_collection_links", force: :cascade do |t|
    t.integer  "user_id",              limit: 4, null: false
    t.integer  "agency_collection_id", limit: 4, null: false
    t.integer  "role",                 limit: 4, null: false
    t.integer  "created_by",           limit: 4
    t.integer  "updated_by",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_house_contract_pics", force: :cascade do |t|
    t.integer  "user_house_contract_id", limit: 4,   null: false
    t.string   "picture_file_name",      limit: 255
    t.string   "picture_content_type",   limit: 255
    t.integer  "picture_file_size",      limit: 4
    t.datetime "picture_updated_at"
    t.string   "about_pic",              limit: 255
    t.boolean  "primary_pic"
    t.integer  "created_by",             limit: 4
    t.integer  "updated_by",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_house_contracts", force: :cascade do |t|
    t.integer  "user_house_link_id",  limit: 4
    t.datetime "contract_start_date",                             null: false
    t.datetime "contract_end_date",                               null: false
    t.float    "annual_rent_amount",  limit: 24,   default: 0.0
    t.boolean  "active",                           default: true
    t.integer  "created_by",          limit: 4
    t.integer  "updated_by",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",             limit: 4,                   null: false
    t.integer  "house_id",            limit: 4,                   null: false
    t.integer  "role",                limit: 4,    default: 0
    t.float    "monthly_rent_amount", limit: 24,   default: 0.0
    t.string   "note",                limit: 1000
    t.integer  "next_contract_id",    limit: 4
    t.integer  "contract_type",       limit: 1,    default: 1
    t.boolean  "onetime_contract",                 default: false
  end

  create_table "user_house_links", force: :cascade do |t|
    t.integer  "user_id",                limit: 4,                 null: false
    t.integer  "house_id",               limit: 4,                 null: false
    t.integer  "role",                   limit: 4,  default: 0,    null: false
    t.float    "processing_fee",         limit: 24, default: 0.0
    t.integer  "total_renewals",         limit: 4,  default: 0
    t.integer  "total_pending_payments", limit: 4,  default: 0
    t.integer  "total_fail_payments",    limit: 4,  default: 0
    t.integer  "total_success_payments", limit: 4,  default: 0
    t.integer  "user_house_contract_id", limit: 4,  default: 0
    t.boolean  "active",                            default: true
    t.integer  "created_by",             limit: 4
    t.integer  "updated_by",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_property_mgmt_links", force: :cascade do |t|
    t.integer  "user_id",          limit: 4, null: false
    t.integer  "property_mgmt_id", limit: 4, null: false
    t.integer  "role",             limit: 4, null: false
    t.integer  "created_by",       limit: 4
    t.integer  "updated_by",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                   limit: 255,                 null: false
    t.string   "email",                   limit: 255,                 null: false
    t.string   "crypted_password",        limit: 255,                 null: false
    t.string   "password_salt",           limit: 255,                 null: false
    t.string   "persistence_token",       limit: 255,                 null: false
    t.string   "single_access_token",     limit: 255,                 null: false
    t.string   "perishable_token",        limit: 255,                 null: false
    t.integer  "login_count",             limit: 4,   default: 0,     null: false
    t.integer  "failed_login_count",      limit: 4,   default: 0,     null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",        limit: 255
    t.string   "last_login_ip",           limit: 255
    t.string   "fname",                   limit: 255,                 null: false
    t.string   "mname",                   limit: 255,                 null: false
    t.string   "lname",                   limit: 255,                 null: false
    t.integer  "sex",                     limit: 4,   default: 0
    t.integer  "role",                    limit: 4,   default: 0,     null: false
    t.string   "addr1",                   limit: 255,                 null: false
    t.string   "addr2",                   limit: 255
    t.string   "addr3",                   limit: 255
    t.string   "addr4",                   limit: 255
    t.string   "phone1",                  limit: 255,                 null: false
    t.string   "phone2",                  limit: 255
    t.integer  "total_own_houses",        limit: 4,   default: 0
    t.integer  "total_houses_tenant",     limit: 4,   default: 0
    t.datetime "dob"
    t.string   "avatar",                  limit: 255
    t.boolean  "ndelete",                             default: false
    t.boolean  "active",                              default: true
    t.boolean  "approved",                            default: false
    t.boolean  "confirmed",                           default: false
    t.string   "adhaar_no",               limit: 255
    t.string   "avatar_file_name",        limit: 255
    t.string   "avatar_content_type",     limit: 255
    t.integer  "avatar_file_size",        limit: 4
    t.datetime "avatar_updated_at"
    t.boolean  "verified",                            default: false
    t.integer  "created_by",              limit: 4
    t.integer  "updated_by",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "community_id",            limit: 4
    t.integer  "entitlement",             limit: 4,   default: 49920 #User can create these many types of contracts.
    t.integer  "subscription_type",       limit: 4,   default: 1
    t.datetime "subscription_good_until"
  end
  
  
end
