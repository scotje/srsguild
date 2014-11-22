class AddCharacterFields < ActiveRecord::Migration
  def self.up
    add_column :characters, :armory_guild, :string
    add_column :characters, :gender, :string, :length => 1
    add_column :characters, :race, :string
  end

  def self.down
    remove_column :characters, :race
    remove_column :characters, :gender
    remove_column :characters, :armory_guild
  end
end
