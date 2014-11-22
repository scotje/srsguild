class AddSpecsToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :armory_spec1, :string
    add_column :characters, :armory_spec2, :string
    add_column :characters, :raid_spec, :string
  end

  def self.down
    remove_column :characters, :raid_spec
    remove_column :characters, :armory_spec2
    remove_column :characters, :armory_spec1
  end
end
