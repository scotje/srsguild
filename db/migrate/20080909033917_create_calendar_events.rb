class CreateCalendarEvents < ActiveRecord::Migration
  def self.up
    create_table :calendar_events do |t|
      t.belongs_to :guild, :null => false
      t.string :title, :null => false
      t.datetime :begins_at, :null => false
      t.integer :organizer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :calendar_events
  end
end
