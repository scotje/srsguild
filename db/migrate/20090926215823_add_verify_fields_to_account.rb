class AddVerifyFieldsToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :email_verification_value, :string
    add_column :accounts, :email_verify_before, :datetime
    
    add_index :accounts, :email_verification_value, :unique => true
  end

  def self.down
    remove_index :accounts, :column => :email_verification_value
    remove_column :accounts, :email_verify_before
    remove_column :accounts, :email_verification_value
  end
end
