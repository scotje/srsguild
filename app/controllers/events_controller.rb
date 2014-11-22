class EventsController < ApplicationController
  
  before_filter :require_login
  before_filter :require_guild
  
  def index
    @this_week = @_GUILD.calendar_events.find(:all, :conditions => CalendarEvent.conditions_for_raid_week(Date.today), :order => "begins_at ASC")
    @next_week = @_GUILD.calendar_events.find(:all, :conditions => CalendarEvent.conditions_for_raid_week(Date.today + 7), :order => "begins_at ASC")
    @past_events = @_GUILD.calendar_events.find(:all, :conditions => ["begins_at < ?", Time.new], :order => "begins_at DESC", :limit => 10, :include => :calendar_event_attendances)
  end
  
  def show
    @event = @_GUILD.calendar_events.find(params[:id])
    redirect_to :action => 'index' and return if @event.nil?
    
    @prev_event = @_GUILD.calendar_events.find(:first, :conditions => ["begins_at < ?", @event.begins_at], :order => "begins_at DESC")
    @next_event = @_GUILD.calendar_events.find(:first, :conditions => ["begins_at > ?", @event.begins_at], :order => "begins_at ASC")
    
    @plan_group_slots = Array.new

    (0..7).each do |i|
      @plan_group_slots[i] = Array.new
    end
    
    @event.event_plan_slots.find(:all, :order => 'group_position ASC').each do |s|
      @plan_group_slots[((s.group_position.to_f-1.0)/5.0).floor.to_i].push(s)
    end
    
    @personal_signup = @_MAIN_CHAR.calendar_event_signups.find(:first, :conditions => ["calendar_event_id = ?", @event.id])
  end

  def attendance
    @events = CalendarEvent.paginate :page => params[:page], :order => 'begins_at DESC', :per_page => 20, :conditions => ["guild_id = ? AND begins_at < ?", @_GUILD.id, Time.new], :include => :calendar_event_attendances
  end
end
