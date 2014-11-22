class MoreCharacterMetadata < ActiveRecord::Migration
  def self.up
    add_column :characters, :guild_role, :string
    add_column :characters, :is_main, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :characters, :is_main
    remove_column :characters, :guild_role
  end
end
