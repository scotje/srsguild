class FixCharacterNameIndexToUnique < ActiveRecord::Migration
  def self.up
    add_index :characters, [:name, :guild_id], :unique => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
