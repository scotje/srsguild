class Guild < ActiveRecord::Base
  attr_accessible :name, :realm, :region, :subdomain

  belongs_to :owner, :class_name => 'Account'
  
  has_many :characters, :dependent => :nullify
  has_many :main_characters, :class_name => 'Character', :conditions => "is_main = 1"
  has_many :calendar_events, :conditions => "is_deleted = 0", :dependent => :destroy
  has_many :balance_accounts, :conditions => "is_deleted = 0", :dependent => :destroy
  
  has_one :guild_config, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :realm
  validates_presence_of :region
  validates_presence_of :owner_id
  
  validates_uniqueness_of :name, :scope => [ :realm, :region ], :message => "Someone has already set up an account for this guild."
  validates_presence_of :subdomain, :message => "The subdomain cannot be blank."
  validates_format_of :subdomain, :with => /^[a-z0-9-]+$/, :message => 'The subdomain can only contain letters, numbers, and dashes.', :allow_blank => true
  validates_uniqueness_of :subdomain, :case_sensitive => false, :message => 'That subdomain is already in use.'
  validates_exclusion_of :subdomain, :in => %w( www admin beta mail ftp blog support api billing help forum login auth armory ), :message => "That subdomain is not allowed."
  
  before_validation :downcase_subdomain

  after_create :create_config
  
  def create_config
    # Create a default (blank) GuildConfig row.
    gc = GuildConfig.new
    gc.guild = self
    gc.save!
  end
  
  def join_code
    return self.guild_config.m_join_code || nil
  end
  
  def class_count(char_class, main_only = nil)
    if main_only.nil?
      self.characters.count(:conditions => { :character_class => char_class })
    elsif main_only
      self.main_characters.count(:conditions => { :character_class => char_class })
    else
      self.characters.count(:conditions => { :character_class => char_class, :is_main => false })
    end
  end
  
  def armory_sync_in_progress?
    return self.import_complete == false
  end
  
  def armory_sync_complete?
    return self.import_complete == true
  end
  
  def characters_with_attendance_count(opts = {})
    # This was fun to make!
    
    # SELECT 
    # 	characters.*, 
    # 	COUNT(DISTINCT IF(calendar_events.attendance_policy != 'optional' AND calendar_events.begins_at > '2009-12-23 02:19:00', calendar_event_id, NULL)) AS events_attended, 
    # 	MAX(calendar_events.begins_at) AS last_attended_at 
    # FROM 
    # 	`characters` LEFT JOIN 
    # 	(calendar_event_attendances INNER JOIN calendar_events 
    # 		ON ((calendar_event_attendances.calendar_event_id = calendar_events.id) AND (calendar_events.is_deleted != 1))) 
    # 	ON (characters.id = calendar_event_attendances.character_id) 
    # WHERE 
    # 	`characters`.guild_id = 4 AND `characters`.is_main = 1
    # GROUP BY 
    # 	characters.id 
    # ORDER BY 
    # 	FIELD(characters.guild_role, 'Alt', 'Initiate', 'Member', 'Core', 'Officer', 'Leader') DESC, characters.name ASC
    	    
    if opts[:timespan]
      self.main_characters.find(:all, :select => "characters.*, COUNT(DISTINCT IF(calendar_events.attendance_policy != 'optional' AND calendar_events.begins_at > '#{opts[:timespan].days.ago}' AND calendar_events.begins_at < UTC_TIMESTAMP(), calendar_event_id, NULL)) AS events_attended, MAX(calendar_events.begins_at) AS last_attended_at", :joins => "LEFT JOIN (calendar_event_attendances INNER JOIN calendar_events ON ((calendar_event_attendances.calendar_event_id = calendar_events.id) AND (calendar_events.is_deleted != 1))) ON (characters.id = calendar_event_attendances.character_id)", :group => "characters.id", :order => "FIELD(characters.guild_role, 'Alt', 'Initiate', 'Member', 'Core', 'Officer', 'Leader') DESC, characters.name ASC")
    else
      self.main_characters.find(:all, :select => "characters.*, COUNT(DISTINCT IF(calendar_events.attendance_policy != 'optional' AND calendar_events.begins_at < UTC_TIMESTAMP(), calendar_event_id, NULL)) AS events_attended, MAX(calendar_events.begins_at) AS last_attended_at", :joins => "LEFT JOIN (calendar_event_attendances INNER JOIN calendar_events ON ((calendar_event_attendances.calendar_event_id = calendar_events.id) AND (calendar_events.is_deleted != 1))) ON (characters.id = calendar_event_attendances.character_id)", :group => "characters.id", :order => "FIELD(characters.guild_role, 'Alt', 'Initiate', 'Member', 'Core', 'Officer', 'Leader') DESC, characters.name ASC")
    end
  end
  
  def event_count_for_attendance(opts = {})
    if opts[:timespan]
      self.calendar_events.count(:conditions => ["attendance_policy = 'required' AND begins_at > ? AND begins_at < UTC_TIMESTAMP() AND is_deleted != 1", opts[:timespan].days.ago])
    else
      self.calendar_events.count(:conditions => "attendance_policy = 'required' AND begins_at < UTC_TIMESTAMP() AND is_deleted != 1")
    end
  end
  
  def async_roster_from_armory(min_rank)
    self.import_complete = false
    self.save!
    
    api = Wowr::API.new

    guild = api.get_guild(self[:name], :realm => self[:realm], :locale => self[:region], :caching => false)
    
    if self.faction.blank?
      # TODO: Patch wowr so that it populates faction in the FullGuild object that get_guild returns. It's in the XML.
      sguilds = api.search_guilds(self[:name], :locale => self[:region], :caching => false)
      
      unless sguilds.blank?
        sguilds.each do |sg|
          self.faction = sg.faction if sg.realm == self[:realm]
        end
      end
    end
    
    guild.members.each do |name, m|
      if m.level >= WOW_LEVEL_CAP && m.rank.to_i <= min_rank
        begin
          c = Character.find(:first, :conditions => { :guild_id => self.id, :name => m.name, :realm => self[:realm], :region => self[:region] })
          
          if c.blank?
            c = Character.new
            c.name = m.name
            c.region = self[:region]
            c.realm = self[:realm]
            c.guild_id = self[:id]
            c.gender = ['m','f'][m.gender_id]
            c.character_class = BLIZZARD_CLASS_IDS[m.klass_id]
            c.race = BLIZZARD_RACE_IDS[m.race_id]
            c.armory_sync_requested_at = Time.new
            c.save!
          end
          
          c.send_later(:armory_sync)
        rescue
          # Log failed import of a character.
          logger.info("INFO: Failed to queue sync of '#{m.name}/#{self[:realm]}/#{self[:region]}' for guild #{self[:id]}.\n")
        end
      end
    end
  end
  
  def dummy_roster
    [
      { :name => 'Darksprocket', :class => 'Warlock', :gender => 'm', :race => 'Gnome' },
      { :name => 'Earlorn', :class => 'Mage', :gender => 'm', :race => 'Gnome' },
      { :name => 'Llodonnix', :class => 'Rogue', :gender => 'm', :race => 'Dwarf' },
      { :name => 'Malformed', :class => 'Shaman', :gender => 'm', :race => 'Draenei' },
      { :name => 'Reverand', :class => 'Priest', :gender => 'm', :race => 'Dwarf' },
      { :name => 'Guacamolito', :class => 'Hunter', :gender => 'm', :race => 'Draenei' },
      { :name => 'Antigonus', :class => 'Paladin', :gender => 'm', :race => 'Human' },
      { :name => 'Zija', :class => 'Druid', :gender => 'f', :race => 'Night Elf' },
      { :name => 'Gaerlan', :class => 'Priest', :gender => 'f', :race => 'Night Elf' },
      { :name => 'Boddington', :class => 'Death Knight', :gender => 'm', :race => 'Dwarf' },
      { :name => 'Timevampire', :class => 'Warlock', :gender => 'm', :race => 'Gnome' },
      { :name => 'Joekickass', :class => 'Warrior', :gender => 'm', :race => 'Gnome' },
      { :name => 'Reanimatress', :class => 'Priest', :gender => 'f', :race => 'Draenei' },
      { :name => 'Rhicter', :class => 'Shaman', :gender => 'm', :race => 'Draenei' },
      { :name => 'Terrwyn', :class => 'Paladin', :gender => 'f', :race => 'Human' },
      { :name => 'Morli', :class => 'Rogue', :gender => 'm', :race => 'Dwarf' },
      { :name => 'Bruneith', :class => 'Hunter', :gender => 'm', :race => 'Dwarf' },
      { :name => 'Amberdawn', :class => 'Druid', :gender => 'f', :race => 'Night Elf' },
      { :name => 'Afterburner', :class => 'Mage', :gender => 'm', :race => 'Gnome' },
      { :name => 'Mirovan', :class => 'Mage', :gender => 'f', :race => 'Human' },
      { :name => 'Dreadraven', :class => 'Death Knight', :gender => 'f', :race => 'Human' },
      { :name => 'Deadbow', :class => 'Hunter', :gender => 'm', :race => 'Night Elf' },
      { :name => 'Taritos', :class => 'Paladin', :gender => 'm', :race => 'Human' },
      { :name => 'Sturmrider', :class => 'Paladin', :gender => 'm', :race => 'Human' },
      { :name => 'Devinelight', :class => 'Priest', :gender => 'f', :race => 'Human' },
      { :name => 'Dancingjoker', :class => 'Rogue', :gender => 'm', :race => 'Human' },
      { :name => 'Shabadoo', :class => 'Shaman', :gender => 'm', :race => 'Draenei' },
      { :name => 'Coletta', :class => 'Shaman', :gender => 'f', :race => 'Draenei' },
      { :name => 'Asamash', :class => 'Warrior', :gender => 'm', :race => 'Human' },
      { :name => 'Stabadoo', :class => 'Rogue', :gender => 'm', :race => 'Gnome' }
    ]
  end
  
  def dummy_signup(event)
    self.characters.sort_by{rand}[0..28].each do |c|
      unless c.signed_up_for?(event)
        c.signup_for_event(event)
      end
    end
  end
  
  def new_dummy_char(name, char_class, gender, race)
    acct = Account.new
    
    acct.email = "demo_#{rand(99)}#{Time.new.to_i.to_s}#{rand(99)}@srsguild.com"
    acct.password = "demo123"
    acct.password_confirmation = "demo123"
    acct.skip_email_validation = true

    acct.save!
    
    
    char = Character.new
    
    char.account = acct
    char.guild = self
    char.is_main = true
    char.guild_role = 'Core'
    char.name = name
    char.character_class = char_class
    char.region = self.region
    char.realm = self.realm
    char.gender = gender
    char.race = race

    char.save!
  end
  
  def add_demo_attendees(event)
  	event.calendar_event_attendances.clear

  	["Afterburner", "Amberdawn", "Antigonus", "Bruneith", "Coletta", "Dancingjoker", "Darksprocket",
  	"Deadbow", "Devinelight", "Dreadraven", "Earlorn", "Guacamolito", "Hacknslash", "Joekickass",
  	"Llodonnix", "Malformed", "Miroven", "Morli", "Reanimatress", "Reverand", "Rhicter", "Shabadoo",
  	"Sturmrider", "Taritus", "Timevampire", "Zija"].each do |charname|
  		char = self.main_characters.find_by_name(charname)

  		new_att = CalendarEventAttendance.new
  		new_att.character = char
  		new_att.calendar_event = event

  		new_att.save!
  	end
  end    
  
  protected

  def downcase_subdomain
    self.subdomain.downcase! if attribute_present?("subdomain")
  end
end
