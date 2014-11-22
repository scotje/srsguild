class RosterController < ApplicationController
  
  before_filter :require_login

  def index
    @roster = @_GUILD.characters_with_attendance_count(:timespan => session[:roster_filters][:timespan])
    @event_count = @_GUILD.event_count_for_attendance(:timespan => session[:roster_filters][:timespan])
  end
  
  def show
    @char = @_GUILD.characters.find(params[:id])
    @past_events = @_GUILD.calendar_events.find(:all, :conditions => ["begins_at < ?", Time.new], :order => "begins_at DESC", :limit => 10, :include => :calendar_event_attendances)
    @balance_accounts = @_GUILD.balance_accounts.with_balances_for_character(@_MAIN_CHAR.id).find(:all, :order => 'name ASC')
  end
  
  def filter
    if params[:timespan] and params[:timespan].blank?
      session[:roster_filters][:timespan] = nil
    else
      session[:roster_filters][:timespan] = params[:timespan].to_i if (30..365).include?(params[:timespan].to_i)
    end
    
    redirect_to :back and return
  end

end
