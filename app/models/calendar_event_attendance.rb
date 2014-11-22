class CalendarEventAttendance < ActiveRecord::Base
  belongs_to :calendar_event
  belongs_to :character

  def character_name
    return character.name if character
  end
  
  def character_name=(name)
    self.character = Character.find_by_name(name) unless name.blank?
  end
end
