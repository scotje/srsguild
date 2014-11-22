class Admin::AdminController < ApplicationController
  before_filter :require_login
  before_filter :reauthenticate_user
  before_filter :require_guild
  before_filter :require_guild_admin
  before_filter :admin_includes
  
  layout 'admin'
  
  protected
  #---------------------------------------------------------------------------
  def reauthenticate_user
    if (session[:admin_auth_at] and (session[:admin_auth_at] > (Time.new - 30.minutes)))
      # They have re-authenticated to the admin area and done something here in the last 30 minutes. Reset the timer and continue.
      session[:admin_auth_at] = Time.new
      return true
    else
      # They have not re-authenticated this login or it has been more than 30 minutes since they did something adminy.
      flash[:warning] = "You must re-verify your login information to access this area."
      redirect_to :controller => '/sessions', :action => 'new', :for_admin => true and return
    end
  end
  
  def require_guild_admin
    # They have admin if they are the owner.
    return true if @_GUILD.owner == @_USER
    
    if @_MAIN_CHAR
      return true if @_MAIN_CHAR.is_admin
    end
    
    redirect_to guild_url
  end
  
  def admin_includes
    @admin = true
  end
end
