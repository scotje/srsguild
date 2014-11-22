class AddDeletedFlagToEvents < ActiveRecord::Migration
  def self.up
    add_column :calendar_events, :is_deleted, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :calendar_events, :is_deleted
  end
end
