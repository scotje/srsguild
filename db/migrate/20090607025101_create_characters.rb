class CreateCharacters < ActiveRecord::Migration
  def self.up
    create_table :characters do |t|
      t.belongs_to :account, :null => false
      t.string :name, :null => false
      t.belongs_to :guild
      t.string :character_class, :null => false
      t.string :region, :null => false, :limit => 2
      t.string :realm, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :characters
  end
end
