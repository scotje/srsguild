class CreateEventPlanSlots < ActiveRecord::Migration
  def self.up
    create_table :event_plan_slots do |t|
      t.belongs_to :calendar_event
      t.belongs_to :character
      t.column :group_position, :integer
      t.column :group_role, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :event_plan_slots
  end
end
