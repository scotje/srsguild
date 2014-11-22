class SignupsController < ApplicationController
  before_filter :require_login
  before_filter :require_guild

  def toggle
    @event = @_GUILD.calendar_events.find(params[:event_id])
    
    if @_MAIN_CHAR.signed_up_for?(@event)
      @_MAIN_CHAR.vacate_signup_for_event(@event)
    else
      @_MAIN_CHAR.signup_for_event(@event)
    end
    
    respond_to do |wants|
      wants.html { redirect_to event_url(@event) and return }
      wants.js { render :layout => false }
    end
  end
  
  def update
    #char = @_USER.characters.find(params[:my_signup_character])
    char = @_USER.main_character
    event = @_GUILD.calendar_events.find(params[:event_id])
    signup = char.calendar_event_signups.find(:first, :conditions => { :calendar_event_id => event.id })

    # Make sure this is a signup they can change.
    if (event.begins_at < Time.new)
      flash[:error] = "You can't modify that signup. (Perhaps the event has already begun?)"
      redirect_to event_url(event) and return
    end

		params[:my_signup_role] = nil if params[:my_signup_role].blank?
		params[:my_signup_comments] = nil if params[:my_signup_comments].blank?
    
    signup.character = char
    signup.role_preference = params[:my_signup_role]
    signup.comments = params[:my_signup_comments]
    
    signup.save!
    
    flash[:notice] = "Your signup has been updated for this event."
    redirect_to event_url(event)
  end
  
  def create
    #char = @_USER.characters.find(params[:my_signup_character])
    char = @_USER.main_character
    event = @_GUILD.calendar_events.find(params[:event_id])

    signup = CalendarEventSignup.new
    signup.calendar_event = event
    signup.character = char
    
    signup.role_preference = params[:my_signup_role] unless params[:my_signup_role].blank?
    signup.comments = params[:my_signup_comments] unless params[:my_signup_comments].blank?
    
    signup.save!
    
    flash[:notice] = "You have been signed up for this event."
    redirect_to event_url(event)
  end
  
  def destroy
    char = @_USER.main_character
    event = @_GUILD.calendar_events.find(params[:event_id])
    signup = char.calendar_event_signups.find(:first, :conditions => { :calendar_event_id => event.id })

    signup.destroy
    
    flash[:notice] = "Your signup for this event has been cancelled."
    redirect_to event_url(event)
  end
end
