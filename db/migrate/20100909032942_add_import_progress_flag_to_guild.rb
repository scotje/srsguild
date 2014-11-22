class AddImportProgressFlagToGuild < ActiveRecord::Migration
  def self.up
    # this should be null if an import has not been requested, 0 (false) if 
    # an import is in progress, and 1 (true) if an import has completed but 
    # the user has not been notified yet
    add_column :guilds, :import_complete, :boolean, :default => nil
  end

  def self.down
    remove_column :guilds, :import_complete
  end
end
