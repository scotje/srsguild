class AddTimezoneToAccountAndGuild < ActiveRecord::Migration
  def self.up
    add_column :accounts, :time_zone, :string
    add_column :guild_configs, :default_time_zone, :string

  end

  def self.down
    remove_column :guild_configs, :default_time_zone
    remove_column :accounts, :time_zone
  end
end
