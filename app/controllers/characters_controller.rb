class CharactersController < ApplicationController

  before_filter :require_login
  verify :method => :post, :only => [:create, :join]

  def index
    redirect_to :controller => '/account', :action => 'index' and return
  end

  def new
    if flash[:new_character].blank?
      @character = Character.new

      if @_MAIN_CHAR
        @character.region = @_MAIN_CHAR.region
        @character.realm = @_MAIN_CHAR.realm
      elsif @_GUILD
        @character.region = @_GUILD.region
        @character.realm = @_GUILD.realm
      end
    else
      @character = Character.new(flash[:new_character])
    end

    @extended_fields = true if flash[:armory_error]
  end
  
  def create
    char = Character.new(params[:character])
    char.account = @_USER
    
    if @_USER.characters.blank?
      char.is_main = true
      char.guild_role = 'Initiate'
      char.guild = @_GUILD unless @_GUILD.nil?
    else
      char.is_main = false
      char.guild = @_USER.main_character.guild unless @_USER.main_character.guild.nil?
      char.guild_role = 'Alt'
    end
    
    if char.valid?
      char.save!
      
      redirect_to :controller => 'characters', :action => 'index' and return
    elsif char.errors.on_base.include?("armory_update_error")
      flash[:armory_error] = true
      flash[:new_character] = params[:character]

      redirect_to :controller => 'characters', :action => 'new' and return
    else
      flash[:error] = "Whoops! Something was wrong with the information you provided."
      flash[:errors] = char.errors

      redirect_to :controller => 'characters', :action => 'new' and return
    end
  end
  
  def update
    char = @_USER.characters.find(params[:id])

    params[:main_char][:event_role_preference] = nil if params[:main_char][:event_role_preference].blank?

    if char.update_attributes(params[:main_char])
      flash[:notice] = "Character settings saved."
    else
      flash[:error] = "Unable to save character settings."
    end
    
    redirect_to account_url
  end
  
  def promote
    char = @_USER.characters.find(params[:id])
    current_main = @_USER.main_character
    
    Character.transaction do
      char.guild_role = current_main.guild_role
      
      current_main.is_main = false
      current_main.guild_role = 'Alt'
      current_main.save!
      
      char.is_main = true
      char.save!
    end
    
    redirect_to :action => 'index' and return
  end
  
  def join
    char = @_USER.characters.find(params[:id])

    guild = Guild.find(params[:guild_id])
    
    unless guild.nil?
      if params[:join_code].strip == guild.join_code
        # Check to see if there is an unclaimed character in the guild already.
        unclaimed = guild.characters.find(:first, :conditions => { :name => char.name, :account_id => nil })

        if unclaimed
          Character.transaction do
            unclaimed.account = @_USER
            unclaimed.guild_role = 'Initiate' if unclaimed.guild_role.blank?
          
            # Copy user controllable settings into the unclaimed character.
            unclaimed.is_main = char.is_main
            unclaimed.event_role_preference = char.event_role_preference
            unclaimed.armory_spec1 = char.armory_spec1
            unclaimed.armory_spec2 = char.armory_spec2
            unclaimed.raid_spec = char.raid_spec
          
            unclaimed.save!
          
            # Destroy the user created character.
            char.destroy
          end
        else
          char.guild = guild
          char.guild_role = 'Initiate'
          char.save!
        end
        
        # Add any alts to this guild as well.
        @_USER.alt_characters.each do |c|
          c.guild = guild
          c.guild_role = 'Alt'
          c.save!
        end
        
        flash[:notice] = "Character successfully joined to guild."
        redirect_to :controller => '/account', :action => 'index' and return
      else
        flash[:error] = "The join code you supplied was not correct for the selected guild."
        flash[:guild_id] = guild.id
      end
    end

    redirect_to :action => 'find_guild', :id => char and return
  end
  
  def find_guild
    @char = @_USER.characters.find(params[:id])

    @possible_guild = Guild.find(:first, :conditions => ["name = ? AND realm = ? AND region = ?", @char.armory_guild, @char.realm, @char.region])

    if request.post?
      @guilds = Guild.find(:all, :conditions => ["name LIKE ? AND realm = ? AND region = ?", "%#{params[:search_name]}%", params[:search_realm], params[:search_region]])
    elsif flash[:guild_id]
      @guilds = Guild.find(:all, :conditions => ["id = ?", flash[:guild_id].to_i])
    end
  end
  
  def withdraw
    char = @_USER.characters.find(params[:id])
    
    char.withdraw

    flash[:notice] = "Character removed from guild."

    redirect_to :action => 'index' and return
  end
  
  def armory_update
    char = @_USER.characters.find(params[:id])
    
    if char.update_from_armory
      char.save!
      flash[:notice] = "Character information updated from Armory."
    else
      flash[:error] = "Unable to update character information from Armory."
    end

    redirect_to :action => 'index' and return
  end
  
  def destroy
    char = @_USER.characters.find(params[:id])
    
    if char == @_MAIN_CHAR
      flash[:error] = "You cannot remove your main character."
    else
      char.destroy
      flash[:notice] = "Character removed."
    end

    redirect_to :action => 'index' and return
  end
  

end
