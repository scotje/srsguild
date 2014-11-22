class AddResetPasswordFields < ActiveRecord::Migration
  def self.up
    add_column :accounts, :password_reset_value, :string
    add_column :accounts, :password_reset_request_at, :datetime
    add_column :accounts, :password_reset_ip, :string
  end

  def self.down
    remove_column :accounts, :password_reset_ip
    remove_column :accounts, :password_reset_request_at
    remove_column :accounts, :password_reset_value
  end
end
