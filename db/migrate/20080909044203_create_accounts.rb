class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :email, :pw_hash, :pw_salt
      
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
