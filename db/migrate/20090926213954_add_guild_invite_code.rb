class AddGuildInviteCode < ActiveRecord::Migration
  def self.up
    add_column :guilds, :join_code, :string, :limit => 6, :null => true
    add_index :guilds, :join_code, :unique => true
    
    add_index :guilds, [:name, :realm, :region], :unique => true
  end

  def self.down
    remove_index :guilds, :column => [:name, :realm, :region]
    remove_index :guilds, :join_code
    remove_column :guilds, :join_code
  end
end
