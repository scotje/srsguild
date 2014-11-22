class Admin::PlansController < Admin::AdminController

  before_filter :with_jquery
  skip_before_filter :reauthenticate_user, :only => [ :stats ]

  def index
    @next_ten_events = @_GUILD.calendar_events.find(:all, :conditions => "begins_at > UTC_TIMESTAMP()", :order => "begins_at ASC", :limit => 10)
  end
  
  def show
    @event = @_GUILD.calendar_events.find(params[:event_id])
    
    @chars_in_groups = Array.new
    @group_slots = Array.new
    
    (0..7).each do |i|
      @group_slots[i] = Array.new
    end
    
    @raidcomp_key = "0000000000000000000000000000000000000000"

    @event.event_plan_slots.each do |s|
      @group_slots[((s.group_position.to_f-1.0)/5.0).floor.to_i].push(s)
      @chars_in_groups << s.character.id

      @raidcomp_key[s.group_position-1] = s.character.raidcomp_key
    end
    
    if @chars_in_groups.empty?
      @backups = @event.calendar_event_signups.find(:all, :order => 'characters.name ASC')
    else
      @backups = @event.calendar_event_signups.find(:all, :conditions => ["character_id NOT IN (?)", @chars_in_groups], :order => 'characters.name ASC')
    end
  end
  
  def update
    @event = @_GUILD.calendar_events.find(params[:event_id])
    
    @event.event_plan_slots.clear
    
    unless params[:group_setup].blank?
      params[:group_setup].each do |group_id, characters|
        group_id = group_id.split("-").reverse.first.to_i
        
        unless characters.blank?
          characters.each_with_index do |char_id, i|
            char_id = char_id.split("-").reverse.first.to_i
            char = @_GUILD.characters.find(char_id)
            
            plan_slot = EventPlanSlot.new
            plan_slot.group_position = i+((group_id-1)*5)+1
            plan_slot.calendar_event = @event
            plan_slot.character = char
            
            plan_slot.save
          end
        end
      end
    end
    
    #redirect_to admin_event_plan_url(@event)
    render :text => "success"
  end
  
  def stats
    @event = @_GUILD.calendar_events.find(params[:event_id])
    
    @raidcomp_key = "0000000000000000000000000000000000000000"
    @event.event_plan_slots.each do |ps|
      @raidcomp_key[ps.group_position-1] = ps.character.raidcomp_key
    end
    
    render :partial => 'event_plan_stats'
  end
end
