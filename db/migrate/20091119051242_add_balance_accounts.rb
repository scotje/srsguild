class AddBalanceAccounts < ActiveRecord::Migration
  def self.up
    create_table :balance_accounts, :force => true do |t|
      t.belongs_to :guild, :null => false
      t.column :name, :string, :null => false
      t.column :account_type, :string, :null => false
      t.column :decay_percent, :integer, :null => false, :default => 0
      t.column :active, :boolean
      t.timestamps
    end
    
    create_table :character_balances, :force => true do |t|
      t.belongs_to :character, :null => false
      t.belongs_to :balance_account, :null => false
      t.column :balance, :decimal, :precision => 12, :scale => 2, :null => false, :default => 0.0
      t.timestamps
    end
    
    create_table :balance_transactions, :force => true do |t|
      t.belongs_to :character_balance, :null => false
      t.column :adjustment, :decimal, :precision => 12, :scale => 2, :null => false
      t.column :modified_by, :string, :null => false, :default => "System"
      t.column :comment, :text
      t.belongs_to :calendar_event, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :balance_transactions
    drop_table :character_balances
    drop_table :balance_accounts
  end
end
