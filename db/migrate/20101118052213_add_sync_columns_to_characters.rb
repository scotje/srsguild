class AddSyncColumnsToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :armory_sync_requested_at, :datetime
  end

  def self.down
    remove_column :characters, :armory_sync_requested_at
  end
end
