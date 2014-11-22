class AddRealmsToDatabase < ActiveRecord::Migration
  def self.up
    create_table :realms, :force => true do |t|
      t.column :game, :string, :null => false
      t.column :region, :string, :null => false
      t.column :subregion, :string, :default => nil
      t.column :realm_type, :string, :null => false
      t.column :name, :string, :null => false
      t.timestamps
    end
    
    add_index :realms, :game
    add_index :realms, :region
    add_index :realms, :subregion
    add_index :realms, :realm_type
    add_index :realms, :name
    
    add_index :realms, [:game, :region, :name], :unique => true
  end

  def self.down
    remove_index :realms, :column => [:game, :region, :name]
    remove_index :realms, :name
    remove_index :realms, :realm_type
    remove_index :realms, :subregion
    remove_index :realms, :region
    remove_index :realms, :game

    drop_table :realms
  end
end
