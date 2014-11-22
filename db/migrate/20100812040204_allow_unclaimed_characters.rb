class AllowUnclaimedCharacters < ActiveRecord::Migration
  def self.up
    change_column :characters, :account_id, :integer, :null => true, :default => nil
  end

  def self.down
    change_column :characters, :account_id, :integer, :null => false
  end
end
