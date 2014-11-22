class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :accounts, :email, :unique => true
    add_index :accounts, :password_reset_value, :unique => true
    
    add_index :balance_accounts, :guild_id
    add_index :balance_accounts, :decay_percent
    add_index :balance_accounts, :active
    add_index :balance_accounts, :is_deleted
    add_index :balance_accounts, :last_decayed_at
    
    add_index :balance_transactions, :character_balance_id
    add_index :balance_transactions, :calendar_event_id
    
    add_index :calendar_events, :guild_id
    add_index :calendar_events, :begins_at
    add_index :calendar_events, :attendance_policy
    
    add_index :calendar_event_attendances, :calendar_event_id
    add_index :calendar_event_attendances, :character_id
    
    add_index :calendar_event_signups, :calendar_event_id
    add_index :calendar_event_signups, :character_id
    add_index :calendar_event_signups, :role_preference

    add_index :characters, :account_id
    add_index :characters, :name
    add_index :characters, :guild_id
    add_index :characters, :character_class
    add_index :characters, :guild_role
    add_index :characters, :is_main
    add_index :characters, :is_admin
    add_index :characters, :is_deleted
    
    add_index :character_balances, :character_id
    add_index :character_balances, :balance_account_id
    add_index :character_balances, :balance
    
    add_index :guilds, :subdomain
    
    add_index :guild_configs, :guild_id
    add_index :guild_configs, :m_join_code
  end

  def self.down
    remove_index :guild_configs, :m_join_code
    remove_index :guild_configs, :guild_id
    
    remove_index :guilds, :subdomain
    
    remove_index :character_balances, :balance
    remove_index :character_balances, :balance_account_id
    remove_index :character_balances, :character_id
        
    remove_index :characters, :is_deleted
    remove_index :characters, :is_admin
    remove_index :characters, :is_main
    remove_index :characters, :guild_role
    remove_index :characters, :character_class
    remove_index :characters, :guild_id
    remove_index :characters, :name
    remove_index :characters, :account_id

    remove_index :calendar_event_signups, :role_preference
    remove_index :calendar_event_signups, :character_id
    remove_index :calendar_event_signups, :calendar_event_id

    remove_index :calendar_event_attendances, :character_id
    remove_index :calendar_event_attendances, :calendar_event_id
    
    remove_index :calendar_events, :attendance_policy
    remove_index :calendar_events, :begins_at
    remove_index :calendar_events, :guild_id

    remove_index :balance_transactions, :calendar_event_id
    remove_index :balance_transactions, :character_balance_id
    
    remove_index :balance_accounts, :last_decayed_at
    remove_index :balance_accounts, :is_deleted
    remove_index :balance_accounts, :active
    remove_index :balance_accounts, :decay_percent
    remove_index :balance_accounts, :guild_id

    remove_index :accounts, :column => :password_reset_value
    remove_index :accounts, :column => :email
  end
end
