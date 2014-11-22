class FleshOutCalendarModels < ActiveRecord::Migration
  def self.up
    add_column :calendar_events, :comments, :text
    add_column :calendar_events, :attendance_policy, :string, :null => false, :default => 'required'
    
    create_table :calendar_event_signups, :force => true do |t|
      t.belongs_to :calendar_event, :null => false
      t.belongs_to :character, :null => false
      t.column :role_preference, :string
      t.column :comments, :text
      t.timestamps
    end
    
    create_table :calendar_event_attendances, :force => true do |t|
      t.belongs_to :calendar_event, :null => false
      t.belongs_to :character, :null => false
      t.column :comments, :text
      t.timestamps
    end
    
    change_column :calendar_events, :guild_id, :integer, :null => false
    change_column :calendar_events, :title, :string, :null => false
    change_column :calendar_events, :begins_at, :datetime, :null => false
    change_column :calendar_events, :organizer, :integer, :null => false
  end

  def self.down
    drop_table :calendar_event_attendances
    drop_table :calendar_event_signups
    remove_column :calendar_events, :attendance_policy
    remove_column :calendar_events, :comments
  end
end
