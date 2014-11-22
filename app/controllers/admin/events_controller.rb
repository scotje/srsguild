class Admin::EventsController < Admin::AdminController

  def index
    @this_week = @_GUILD.calendar_events.find(:all, :conditions => CalendarEvent.conditions_for_raid_week(Date.today), :order => "begins_at ASC")
    @future_events = @_GUILD.calendar_events.find(:all, :conditions => ["begins_at > ?", CalendarEvent.end_of_raid_week(Date.today) - Time.new.gmt_offset], :order => "begins_at ASC")
    @recent_events = @_GUILD.calendar_events.find(:all, :conditions => "begins_at < UTC_TIMESTAMP()", :order => "begins_at DESC", :limit => 5)
    
    @current_event = @_GUILD.calendar_events.find(:first, :conditions => ["begins_at < ?", Time.new], :order => "begins_at DESC")
    @new_attendance = CalendarEventAttendance.new
    
    @event = CalendarEvent.new
    @event.start_time = @_GUILD.guild_config.c_default_start_time if @_GUILD.guild_config.c_default_start_time
  end
  
  def show
    @event = @_GUILD.calendar_events.find(params[:id])

    @prev_event = @_GUILD.calendar_events.find(:first, :conditions => ["begins_at < ?", @event.begins_at], :order => "begins_at DESC")
    @next_event = @_GUILD.calendar_events.find(:first, :conditions => ["begins_at > ?", @event.begins_at], :order => "begins_at ASC")
  end
  
  def create
    @new_event = CalendarEvent.new(params[:event])
    @new_event.start_time = "#{params[:event]['start_time(4i)']}:#{params[:event]['start_time(5i)']}" # Ergh.
    @new_event.organizer = @_GUILD.characters.find(params[:event][:organizer])
    @new_event.guild = @_GUILD

    if @new_event.save
      flash[:notice] = "New event created successfully."
    else
      flash[:error] = "Unable to create new event."
    end

    redirect_to :action => 'index' and return
  end
  
  def edit
    @event = @_GUILD.calendar_events.find(params[:id])
  end
  
  def update
    event = @_GUILD.calendar_events.find(params[:id])
    
    event.attributes = params[:event]
    event.start_time = "#{params[:event]['start_time(4i)']}:#{params[:event]['start_time(5i)']}" # Ergh.
    event.organizer = @_GUILD.characters.find(params[:event][:organizer])

    if event.save
      flash[:notice] = "Event details updated successfully."
    else
      flash[:error] = "Unable to update event details."
    end
    
    redirect_to :action => 'show', :id => event and return
  end
  
  def update_attendance
    event = @_GUILD.calendar_events.find(params[:id])
    
    event.calendar_event_attendances.clear
    
    unless params[:attendance].blank?
      params[:attendance].each do |char_id, att|
        char = @_GUILD.characters.find(att['id'].to_i)
      
        new_att = CalendarEventAttendance.new
        new_att.character = char
        new_att.calendar_event = event
        new_att.comments = att['notes']
      
        new_att.save!
      end
    end
    
    flash[:notice] = "Event attendance updated."
    redirect_to :action => 'show', :id => event.id and return
  end
  
  def destroy
    event = @_GUILD.calendar_events.find(params[:id])
    
    if event.begins_at > Time.new
      event.destroy
    else
      event.is_deleted = true
      event.save!
    end
    
    flash[:notice] = "Event deleted."
    redirect_to admin_events_url and return
  end
  
  # AJAX methods
  # --------------------------------------------------------------------------
  
  def char_attendance_row
    @char = @_GUILD.main_characters.find_by_name(params[:character_name])
    #@char = Character.find_by_name(params[:character_name])
    @count = params[:count].to_i || ""

    if @char.nil?
      render :text => "Not found.", :status => :forbidden, :layout => false and return
    end
    
    exclude = JSON.parse(params[:exclude])
    
    if exclude.any? { |id| id.to_i == @char.id }
      render :text => "That person is already on the list!", :status => :forbidden, :layout => false and return
    end
    
    render :partial => 'char_attendance_row', :layout => false
  end
end
