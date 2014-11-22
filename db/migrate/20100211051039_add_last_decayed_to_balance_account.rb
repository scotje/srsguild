class AddLastDecayedToBalanceAccount < ActiveRecord::Migration
  def self.up
    add_column :balance_accounts, :last_decayed_at, :datetime, :null => true, :default => nil
  end

  def self.down
    remove_column :balance_accounts, :last_decayed_at
  end
end
