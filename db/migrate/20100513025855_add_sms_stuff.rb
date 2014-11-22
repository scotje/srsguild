class AddSmsStuff < ActiveRecord::Migration
  def self.up
    add_column :accounts, :mobile_number, :string
    
    create_table :sms_sent_logs, :force => true do |t|
      t.column :sent_by, :integer, :null => false
      t.column :from_guild, :integer, :null => false
      t.column :sent_to, :string, :null => false
      t.column :message_length, :string, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :sms_sent_logs
    remove_column :accounts, :mobile_number
  end
end
