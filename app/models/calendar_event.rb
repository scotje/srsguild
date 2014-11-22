class CalendarEvent < ActiveRecord::Base
  attr_accessible :title, :start_date, :comments, :attendance_policy
  
  belongs_to  :guild
  belongs_to  :organizer, :class_name => 'Character', :foreign_key => 'organizer'
  
  has_many :calendar_event_signups, :include => :character, :order => "calendar_event_signups.created_at ASC", :dependent => :delete_all
  has_many :calendar_event_attendances, :include => :character, :order => "characters.name ASC", :dependent => :delete_all
  
  has_many :characters_signed_up, :through => :calendar_event_signups, :source => :character
  has_many :characters_attended, :through => :calendar_event_attendances, :source => :character
  
  has_many :balance_transactions, :dependent => :delete_all
  
  has_many :event_plan_slots, :order => "group_position ASC", :dependent => :delete_all

  validates_presence_of :guild_id
  validates_presence_of :title
  validates_presence_of :begins_at
  validates_presence_of :organizer
  
  validates_inclusion_of :attendance_policy, :in => %w( required optional bonus )
  
  def start_date
    self.begins_at ? self.begins_at.to_date : Time.new.to_date
  end
  
  def start_date=(date)
    #RAILS_DEFAULT_LOGGER.error "\nStart Date set to #{date} #{start_time.strftime("%H:%M")}\n\n"
    self.begins_at = Time.zone.parse("#{date} #{start_time.strftime("%H:%M")}")
  end
  
  def start_time
    self.begins_at ? self.begins_at : Time.new
  end
  
  def start_time=(time)
    #RAILS_DEFAULT_LOGGER.error "\nStart Time set to #{start_date} #{time}\n\n"
    self.begins_at = Time.zone.parse("#{start_date} #{time}")
  end
  
  # Raid Plan Helpers
  def has_plan?
    return !self.event_plan_slots.blank?
  end

  def plan_tank_count
    count = 0
    
    self.event_plan_slots.each do | ps |
      count += 1 if (ps.character.trinity_role == :tank)
    end
    
    return count
  end
  
  def plan_healer_count
    count = 0
    
    self.event_plan_slots.each do | ps |
      count += 1 if (ps.character.trinity_role == :healer)
    end
    
    return count
  end
  
  def plan_ranged_dps_count
    count = 0
    
    self.event_plan_slots.each do | ps |
      count += 1 if (ps.character.trinity_role == :ranged_dps)
    end
    
    return count
  end
  
  def plan_melee_dps_count
    count = 0
    
    self.event_plan_slots.each do | ps |
      count += 1 if (ps.character.trinity_role == :melee_dps)
    end
    
    return count
  end
  
  def plan_unspecified_count
    count = self.event_plan_slots.size - (self.plan_tank_count + self.plan_healer_count + self.plan_ranged_dps_count + self.plan_melee_dps_count)
    
    if count > 0
      return count
    else
      return 0
    end
  end
  
  # Raid Week related helpers
  def self.conditions_for_raid_week(date)
    t = Time.new
    
    return ["begins_at BETWEEN ? AND ?", self.start_of_raid_week(date) - t.gmt_offset, self.end_of_raid_week(date) - t.gmt_offset]
  end
  
  def self.end_of_raid_week(date)
    return self.start_of_raid_week(date) + 7.days
  end
  
  def self.start_of_raid_week(date)
    while (date.wday != 2) do
      date = date - 1
    end

    return Time.parse(date.to_s)
  end
end
