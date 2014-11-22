class AddAdminFlagToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :is_admin, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :characters, :is_admin
  end
end
