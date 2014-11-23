class GuildsController < ApplicationController

  before_filter :require_login

  def show
    redirect_to account_url and return unless @_GUILD

    @this_week = @_GUILD.calendar_events.find(:all, :conditions => CalendarEvent.conditions_for_raid_week(Date.today), :order => "begins_at ASC")

    # Clear the import status if it is complete on page load.
    if @_GUILD.armory_sync_complete?
      @_GUILD.import_complete = nil
      @_GUILD.save!
    end
  end

  def new
    @guild = Guild.new

    @guild.name = @_USER.main_character.armory_guild rescue nil
    @guild.region = @_USER.main_character.region rescue nil
    @guild.realm = @_USER.main_character.realm rescue nil
  end

  def create
    guild = Guild.new(params[:guild])

    guild.owner = @_USER

    unless @_USER.main_character.nil?
      guild.faction = @_USER.main_character.faction
      guild.characters << @_USER.main_character
    end

    if guild.valid?
      guild.import_complete = false
      guild.save!

      min_rank = params[:min_rank].to_i rescue 7

      guild.send_later(:async_roster_from_armory, min_rank)

      redirect_to guild_url and return
    else
      flash[:error] = "Correct the following problems and try again:<br /> "
      guild.errors.each{|attr,msg| flash[:error] += "#{attr} - #{msg}<br />" }

      redirect_to new_guild_url and return
    end
  end

  #def edit
  #end
  #
  #def update
  #end
  #
  #def destroy
  #end

  # AJAX

  def _armory_sync_status
    if @_GUILD.armory_sync_in_progress?
      render :json => { :status => 'in_progress' }
    elsif @_GUILD.armory_sync_complete?
      render :json => { :status => 'complete' }
    else
      render :json => { :status => 'idle' }
    end
  end

  def _acknowledge_armory_sync_complete
    @_GUILD.import_complete = nil
    @_GUILD.save!

    render :json => { :success => true }
  end
end
