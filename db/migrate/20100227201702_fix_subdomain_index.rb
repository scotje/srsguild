class FixSubdomainIndex < ActiveRecord::Migration
  def self.up
    remove_index :guilds, :subdomain
    
    add_index :guilds, :subdomain, :unique => true
  end

  def self.down
    remove_index :guilds, :subdomain, :unique => true

    add_index :guilds, :subdomain
  end
end
