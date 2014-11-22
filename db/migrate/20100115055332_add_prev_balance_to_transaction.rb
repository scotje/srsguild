class AddPrevBalanceToTransaction < ActiveRecord::Migration
  def self.up
    add_column :balance_transactions, :previous_balance, :decimal, :precision => 12, :scale => 2, :null => false
  end

  def self.down
    remove_column :balance_transactions, :previous_balance
  end
end
