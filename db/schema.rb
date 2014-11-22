# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101118052213) do

  create_table "accounts", :force => true do |t|
    t.string   "email"
    t.string   "pw_hash"
    t.string   "pw_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_verification_value"
    t.datetime "email_verify_before"
    t.string   "time_zone"
    t.string   "password_reset_value"
    t.datetime "password_reset_request_at"
    t.string   "password_reset_ip"
    t.string   "mobile_number"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["email_verification_value"], :name => "index_accounts_on_email_verification_value", :unique => true
  add_index "accounts", ["password_reset_value"], :name => "index_accounts_on_password_reset_value", :unique => true

  create_table "achievement_categories", :force => true do |t|
    t.string   "name",          :null => false
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "achievements", :force => true do |t|
    t.integer  "achievement_category_id", :null => false
    t.integer  "blizzard_id",             :null => false
    t.string   "name",                    :null => false
    t.integer  "criteria_of"
    t.integer  "display_order"
    t.string   "icon_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "balance_accounts", :force => true do |t|
    t.integer  "guild_id",                           :null => false
    t.string   "name",                               :null => false
    t.string   "account_type",                       :null => false
    t.integer  "decay_percent",   :default => 0,     :null => false
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_decayed_at"
    t.boolean  "is_deleted",      :default => false, :null => false
  end

  add_index "balance_accounts", ["active"], :name => "index_balance_accounts_on_active"
  add_index "balance_accounts", ["decay_percent"], :name => "index_balance_accounts_on_decay_percent"
  add_index "balance_accounts", ["guild_id"], :name => "index_balance_accounts_on_guild_id"
  add_index "balance_accounts", ["is_deleted"], :name => "index_balance_accounts_on_is_deleted"
  add_index "balance_accounts", ["last_decayed_at"], :name => "index_balance_accounts_on_last_decayed_at"

  create_table "balance_transactions", :force => true do |t|
    t.integer  "character_balance_id",                                                      :null => false
    t.decimal  "adjustment",           :precision => 12, :scale => 2,                       :null => false
    t.string   "modified_by",                                         :default => "System", :null => false
    t.text     "comment"
    t.integer  "calendar_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "previous_balance",     :precision => 12, :scale => 2,                       :null => false
  end

  add_index "balance_transactions", ["calendar_event_id"], :name => "index_balance_transactions_on_calendar_event_id"
  add_index "balance_transactions", ["character_balance_id"], :name => "index_balance_transactions_on_character_balance_id"

  create_table "calendar_event_attendances", :force => true do |t|
    t.integer  "calendar_event_id", :null => false
    t.integer  "character_id",      :null => false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calendar_event_attendances", ["calendar_event_id"], :name => "index_calendar_event_attendances_on_calendar_event_id"
  add_index "calendar_event_attendances", ["character_id"], :name => "index_calendar_event_attendances_on_character_id"

  create_table "calendar_event_signups", :force => true do |t|
    t.integer  "calendar_event_id", :null => false
    t.integer  "character_id",      :null => false
    t.string   "role_preference"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calendar_event_signups", ["calendar_event_id"], :name => "index_calendar_event_signups_on_calendar_event_id"
  add_index "calendar_event_signups", ["character_id"], :name => "index_calendar_event_signups_on_character_id"
  add_index "calendar_event_signups", ["role_preference"], :name => "index_calendar_event_signups_on_role_preference"

  create_table "calendar_events", :force => true do |t|
    t.integer  "guild_id",                                  :null => false
    t.string   "title",                                     :null => false
    t.datetime "begins_at",                                 :null => false
    t.integer  "organizer",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments"
    t.string   "attendance_policy", :default => "required", :null => false
    t.boolean  "is_deleted",        :default => false,      :null => false
  end

  add_index "calendar_events", ["attendance_policy"], :name => "index_calendar_events_on_attendance_policy"
  add_index "calendar_events", ["begins_at"], :name => "index_calendar_events_on_begins_at"
  add_index "calendar_events", ["guild_id"], :name => "index_calendar_events_on_guild_id"

  create_table "character_achievements", :force => true do |t|
    t.integer  "character_id",   :null => false
    t.integer  "achievement_id", :null => false
    t.datetime "completed_at"
    t.datetime "last_cached_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "character_balances", :force => true do |t|
    t.integer  "character_id",                                                       :null => false
    t.integer  "balance_account_id",                                                 :null => false
    t.decimal  "balance",            :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "character_balances", ["balance"], :name => "index_character_balances_on_balance"
  add_index "character_balances", ["balance_account_id"], :name => "index_character_balances_on_balance_account_id"
  add_index "character_balances", ["character_id"], :name => "index_character_balances_on_character_id"

  create_table "characters", :force => true do |t|
    t.integer  "account_id"
    t.string   "name",                                                     :null => false
    t.integer  "guild_id"
    t.string   "character_class",                                          :null => false
    t.string   "region",                   :limit => 2,                    :null => false
    t.string   "realm",                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "armory_guild"
    t.string   "gender"
    t.string   "race"
    t.string   "guild_role"
    t.boolean  "is_main",                               :default => false, :null => false
    t.boolean  "is_admin",                              :default => false, :null => false
    t.string   "event_role_preference"
    t.boolean  "is_deleted",                            :default => false, :null => false
    t.string   "armory_spec1"
    t.string   "armory_spec2"
    t.string   "raid_spec"
    t.datetime "armory_sync_requested_at"
  end

  add_index "characters", ["account_id"], :name => "index_characters_on_account_id"
  add_index "characters", ["character_class"], :name => "index_characters_on_character_class"
  add_index "characters", ["guild_id"], :name => "index_characters_on_guild_id"
  add_index "characters", ["guild_role"], :name => "index_characters_on_guild_role"
  add_index "characters", ["is_admin"], :name => "index_characters_on_is_admin"
  add_index "characters", ["is_deleted"], :name => "index_characters_on_is_deleted"
  add_index "characters", ["is_main"], :name => "index_characters_on_is_main"
  add_index "characters", ["name", "guild_id"], :name => "index_characters_on_name_and_guild_id", :unique => true
  add_index "characters", ["name"], :name => "index_characters_on_name"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_plan_slots", :force => true do |t|
    t.integer  "calendar_event_id"
    t.integer  "character_id"
    t.integer  "group_position"
    t.string   "group_role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guild_configs", :force => true do |t|
    t.integer  "guild_id",             :null => false
    t.string   "m_join_code"
    t.datetime "c_default_start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_time_zone"
  end

  add_index "guild_configs", ["guild_id"], :name => "index_guild_configs_on_guild_id"
  add_index "guild_configs", ["m_join_code"], :name => "index_guild_configs_on_m_join_code"

  create_table "guilds", :force => true do |t|
    t.string   "name"
    t.string   "realm"
    t.string   "region"
    t.string   "faction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subdomain"
    t.integer  "owner_id",                       :null => false
    t.integer  "plan_level",      :default => 0, :null => false
    t.boolean  "import_complete"
  end

  add_index "guilds", ["name", "realm", "region"], :name => "index_guilds_on_name_and_realm_and_region", :unique => true
  add_index "guilds", ["subdomain"], :name => "index_guilds_on_subdomain", :unique => true

  create_table "realms", :force => true do |t|
    t.string   "game",       :null => false
    t.string   "region",     :null => false
    t.string   "subregion"
    t.string   "realm_type", :null => false
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "realms", ["game", "region", "name"], :name => "index_realms_on_game_and_region_and_name", :unique => true
  add_index "realms", ["game"], :name => "index_realms_on_game"
  add_index "realms", ["name"], :name => "index_realms_on_name"
  add_index "realms", ["realm_type"], :name => "index_realms_on_realm_type"
  add_index "realms", ["region"], :name => "index_realms_on_region"
  add_index "realms", ["subregion"], :name => "index_realms_on_subregion"

  create_table "sms_sent_logs", :force => true do |t|
    t.integer  "sent_by",        :null => false
    t.integer  "from_guild",     :null => false
    t.string   "sent_to",        :null => false
    t.string   "message_length", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
