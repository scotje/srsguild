class EventPlanSlot < ActiveRecord::Base
  belongs_to :character
  belongs_to :calendar_event
end
