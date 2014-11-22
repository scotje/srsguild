class ExpandGuildsTable < ActiveRecord::Migration
  def self.up
    add_column :guilds, :subdomain, :string
    add_column :guilds, :owner_id, :integer, :null => false
  end

  def self.down
    remove_column :guilds, :owner_id
    remove_column :guilds, :subdomain
  end
end
