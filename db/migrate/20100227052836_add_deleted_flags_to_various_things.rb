class AddDeletedFlagsToVariousThings < ActiveRecord::Migration
  def self.up
    add_column :balance_accounts, :is_deleted, :boolean, :null => false, :default => false
    add_column :characters, :is_deleted, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :characters, :is_deleted
    remove_column :balance_accounts, :is_deleted
  end
end
