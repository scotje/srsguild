class CalendarEventSignup < ActiveRecord::Base
  belongs_to :calendar_event
  belongs_to :character
  
  validates_inclusion_of :role_preference, :in => %w( tank healer melee_dps range_dps ), :allow_nil => true
  
  validates_uniqueness_of :character_id, :scope => :calendar_event_id
end
