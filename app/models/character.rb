class Character < ActiveRecord::Base
  belongs_to :account
  belongs_to :guild
  
  has_many :calendar_event_signups
  has_many :calendar_event_attendances
  
  has_many :character_balances
  has_many :balance_accounts, :through => :character_balances, :conditions => "is_deleted = 0"
  has_many :balance_transactions, :through => :character_balances
  
  attr_accessible :name, :character_class, :region, :realm, :gender, :race, :event_role_preference, :raid_spec
  
  validates_presence_of :name, :character_class, :region, :realm, :race, :gender
  validates_inclusion_of :is_main, :in => [true, false], :allow_nil => false
  validates_inclusion_of :guild_role, :in => ['Leader', 'Officer', 'Core', 'Member', 'Initiate', 'Alt'], :allow_nil => true
  validates_inclusion_of :event_role_preference, :in => %w( tank healer melee_dps range_dps ), :allow_nil => true
  
  
  def before_validation_on_create
    update_from_armory if (self.character_class.blank? || self.race.blank? || self.gender.blank?)
  end
  
  def self.find_filters(filters)
    unless filters[:char_class].blank?
      char_class_in = []
      
      filters[:char_class].each do |key, value|
        char_class_in << Character.character_class_from_sym(key)
      end
    end

    ["character_class IN (?)", char_class_in]
  end
  

  def withdraw
    # Perform necessary actions to withdraw from guild.
    
    return unless self.is_main

    self.guild = nil
    self.guild_role = nil
    self.is_admin = false
    self.save!
    
    # Remove any alts from this guild as well.
    self.account.characters.find(:all, :conditions => "guild_id IS NOT NULL").each do |c|
      c.guild = nil
      c.guild_role = nil
      c.is_admin = false
      c.save!
    end

    return true
  end
  
  def raidcomp_key
    return '0' if self.character_class.blank? or self.raid_spec.blank?
    
    case self.character_class
      when 'Death Knight'
        case self.raid_spec
          when /^Blood.*/ then return '1'
          when /^Frost.*/ then return '2'
          when /^Unholy.*/ then return '3'
        end

      when 'Druid'
        case self.raid_spec
          when /^Balance.*/ then return '4'
          when /^Feral.*/ then return '5'
          when /^Restoration.*/ then return '6'
        end
          
      when 'Hunter'
        case self.raid_spec
          when /^Beast.*/ then return '7'
          when /^Marks.*/ then return '8'
          when /^Survival.*/ then return '9'
        end
          
      when 'Mage'
        case self.raid_spec
          when /^Arcane.*/ then return 'a'
          when /^Fire.*/ then return 'b'
          when /^Frost.*/ then return 'c'
        end

      when 'Paladin'
        case self.raid_spec
          when /^Holy.*/ then return 'd'
          when /^Protection.*/ then return 'e'
          when /^Retribution.*/ then return 'f'
        end
          
      when 'Priest'
        case self.raid_spec
          when /^Discipline.*/ then return 'g'
          when /^Holy.*/ then return 'h'
          when /^Shadow.*/ then return 'i'
        end
          
      when 'Rogue'
        case self.raid_spec
          when /^Assassination.*/ then return 'j'
          when /^Combat.*/ then return 'k'
          when /^Subtlety.*/ then return 'l'
        end
          
      when 'Shaman'
        case self.raid_spec
          when /^Elemental.*/ then return 'm'
          when /^Enhancement.*/ then return 'n'
          when /^Restoration.*/ then return 'o'
        end
          
      when 'Warlock'
        case self.raid_spec
          when /^Affliction.*/ then return 'p'
          when /^Demonology.*/ then return 'q'
          when /^Destruction.*/ then return 'r'
        end
          
      when 'Warrior'
        case self.raid_spec
          when /^Arms.*/ then return 's'
          when /^Fury.*/ then return 't'
          when /^Protection.*/ then return 'u'
        end
    end
    
    return '0'
  end
  
  def trinity_role
    # Easy ones first.
    case self.character_class
      when 'Hunter' then return :ranged_dps
      when 'Mage' then return :ranged_dps
      when 'Rogue' then return :melee_dps
      when 'Warlock' then return :ranged_dps
      when 'Death Knight'
        # Since Death Knight specs (at least at the detail that I have) are 
        # ambiguous as to role, we will just go with what they chose for their
        # role preference.
        return nil if self.event_role_preference.blank?
        return self.event_role_preference.to_sym
    end
    
    # If they are a hybrid and we don't know their spec, just go with what
    # they chose for their role preference.
    if self.raid_spec.blank?
      return nil if self.event_role_preference.blank?
      return self.event_role_preference.to_sym
    end
    
    # Hybrid classes.
    case self.character_class
    when 'Druid'
      case self.raid_spec
        when /^Restoration.*/ then return :healer
        when /^Balance.*/ then return :ranged_dps
        when /^Feral.*/
          # Again, Feral is ambiguous with the detail I currently capture.
          return nil if self.event_role_preference.blank?
          return self.event_role_preference.to_sym
        else
          return nil if self.event_role_preference.blank?
          return self.event_role_preference.to_sym
      end
      
    when 'Paladin'
      case self.raid_spec
        when /^Holy.*/ then return :healer
        when /^Protection.*/ then return :tank
        when /^Retribution.*/ then return :melee_dps
        else
          return nil if self.event_role_preference.blank?
          return self.event_role_preference.to_sym
      end
        
    when 'Priest'
      case self.raid_spec
        when /^Discipline.*/ then return :healer
        when /^Holy.*/ then return :healer
        when /^Shadow.*/ then return :ranged_dps
        else
          return nil if self.event_role_preference.blank?
          return self.event_role_preference.to_sym
      end
            
    when 'Shaman'
      case self.raid_spec
        when /^Elemental.*/ then return :ranged_dps
        when /^Enhancement.*/ then return :melee_dps
        when /^Restoration.*/ then return :healer
        else
          return nil if self.event_role_preference.blank?
          return self.event_role_preference.to_sym
      end
            
    when 'Warrior'
      case self.raid_spec
        when /^Arms.*/ then return :melee_dps
        when /^Fury.*/ then return :melee_dps
        when /^Protection.*/ then return :tank
        else
          return nil if self.event_role_preference.blank?
          return self.event_role_preference.to_sym
      end
    end
  end
  
  def signed_up_for?(event)
    return CalendarEventSignup.exists?(["character_id = ? AND calendar_event_id = ?", self[:id], event.id])
  end
  
  def signup_for_event(event)
    ces = CalendarEventSignup.new

    ces.character = self
    ces.calendar_event = event
    ces.role_preference = self.event_role_preference unless self.event_role_preference.blank?

    ces.save!
  end
  
  def vacate_signup_for_event(event)
    CalendarEventSignup.destroy_all(["character_id = ? AND calendar_event_id = ?", self[:id], event.id])
  end

  def attended?(event)
    return CalendarEventAttendance.exists?(["character_id = ? AND calendar_event_id = ?", self[:id], event.id])
  end
  
  def update_from_armory
    api = Wowr::API.new

    begin
      user = api.get_character(self[:name], :realm => self[:realm], :locale => self[:region], :caching => false)

      self[:armory_guild] = user.guild
      self[:character_class] = user.klass
      self[:gender] = user.gender_id == 0 ? 'm' : 'f'
      self[:race] = user.race
      
      self[:armory_spec1] = "#{user.all_talent_specs[0].primary} (#{user.all_talent_specs[0].trees[1..-1].join("/")})"
      default_raid_spec = self[:armory_spec1] if self[:raid_spec].blank?
      
      unless user.all_talent_specs[1].nil?
        self[:armory_spec2] = "#{user.all_talent_specs[1].primary} (#{user.all_talent_specs[1].trees[1..-1].join("/")})"
        
        if user.all_talent_specs[1].active
          default_raid_spec = self[:armory_spec2] if self[:raid_spec].blank?
        end
      end
      
      self[:raid_spec] = default_raid_spec if self[:raid_spec].blank?
      
    rescue
      self.errors.add_to_base("armory_update_error")
      return false
    end
    
    return true
  end
  
  # The new hotness.
  def armory_sync
    # If this is part of a guild sync, check to see if the guild sync has 
    # been waiting too long and mark it as complete if so. Even though it 
    # might still be waiting on some individual characters, we will mark those
    # seperately after 5 minutes.
    if guild && guild.import_complete == false
      if guild.characters.count(:conditions => ["armory_sync_requested_at > ?", 5.minutes.ago ]) == 0
        guild.import_complete = true
        guild.save!
      end
    end
    
    api = Wowr::API.new
    
    ac = api.get_character(self[:name], :realm => self[:realm], :locale => self[:region], :caching => false)
  
    self[:character_class] = ac.klass
    self[:gender] = ac.gender_id == 0 ? 'm' : 'f'
    self[:race] = ac.race

    self[:armory_spec1] = "#{ac.all_talent_specs[0].primary} (#{ac.all_talent_specs[0].trees[1..-1].join("/")})"
    default_raid_spec = self[:armory_spec1] if self[:raid_spec].blank?

    unless ac.all_talent_specs[1].nil?
      self[:armory_spec2] = "#{ac.all_talent_specs[1].primary} (#{ac.all_talent_specs[1].trees[1..-1].join("/")})"

      if ac.all_talent_specs[1].active
        default_raid_spec = self[:armory_spec2] if self[:raid_spec].blank?
      end
    end

    self[:raid_spec] = default_raid_spec if self[:raid_spec].blank?
  
    # Mark the sync as complete.
    self.armory_sync_requested_at = nil
  
    self.save!
    
    # Check to see if all character syncs for this guild are complete.
    if guild && guild.import_complete == false
      if guild.characters.count(:conditions => "armory_sync_requested_at IS NOT NULL") == 0
        guild.import_complete = true
        guild.save!
      end
    end
  end
  
  def all_specs
    specs = Array.new
    specs << self[:armory_spec1] unless self[:armory_spec1].blank?
    specs << self[:armory_spec2] unless self[:armory_spec2].blank?
    
    specs.sort
  end
  
  def faction
    return "Horde" if ['Orc', 'Undead', 'Tauren', 'Troll', 'Blood Elf', 'Goblin'].include?(self[:race])
    return "Alliance" if ['Human', 'Dwarf', 'Night Elf', 'Gnome', 'Draenei', 'Worgen'].include?(self[:race])
    return nil
  end
  
  def character_class_css_name
    return self[:character_class].gsub(/[^\w]/, '').downcase
  end
  
  def icon_path
    gender = self[:gender] == 'm' ? 0 : 1
    
    race_map = {
      'Human' => 1,
      'Orc' => 2,
      'Dwarf' => 3,
      'Night Elf' => 4,
      'Undead' => 5,
      'Tauren' => 6,
      'Gnome' => 7,
      'Troll' => 8,
      'Blood Elf' => 10,
      'Draenei' => 11
    }
    
    class_map = {
      'Death Knight' => 6, 
      'Druid' => 11,
      'Hunter' => 3, 
      'Mage' => 8, 
      'Paladin' => 2, 
      'Priest' => 5, 
      'Rogue' => 4, 
      'Shaman' => 7, 
      'Warlock' => 9, 
      'Warrior' => 1
    }

    return "/images/character_icons/#{gender}-#{race_map[self[:race]]}-#{class_map[self[:character_class]]}.gif"
  end
  
  def self.character_class_from_sym(cc)
    case cc
    when :deathknight
      "Death Knight"
    when :druid
      "Druid"
    when :hunter
      "Hunter"
    when :mage
      "Mage"
    when :paladin
      "Paladin"
    when :priest
      "Priest"
    when :rogue
      "Rogue"
    when :shaman
      "Shaman"
    when :warlock
      "Warlock"
    when :warrior
      "Warrior"
    end
  end
end
