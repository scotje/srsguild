class AddPreferredRoleToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :event_role_preference, :string
  end

  def self.down
    remove_column :characters, :event_role_preference
  end
end
