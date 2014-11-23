# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '2c581709f12cbdc66bebee00bd6e8808'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  filter_parameter_logging :password, :code

  layout "default"

  #before_filter :set_time_zone
  before_filter :init_filters
  #before_filter :realms

  def init_filters
    session[:char_filters] ||= { :char_class => { :deathknight => true, :druid => true, :hunter => true, :mage => true, :paladin => true, :priest => true, :rogue => true, :shaman => true, :warlock => true, :warrior => true }, :char_role => {} }
    session[:roster_filters] ||= { :timespan => 30 }
  end

  def realms
    @_REALMS = Realm.find(:all, :order => 'subregion ASC, name ASC')
  end

  def with_jquery
    @jquery = true
  end


  def check_login
    if session[:logged_in]
      begin
        @_USER = Account.find(session[:user_id])
        @_MAIN_CHAR = @_USER.main_character
        @_GUILD = @_USER.guild # If they are a guild owner this picks it up even without any chars created.
        @_GUILD = @_MAIN_CHAR.guild if (@_GUILD.nil? && !@_MAIN_CHAR.nil?) # This should pick up the guild for non-owners
      rescue
        session[:logged_in] = false
        session[:user_id] = nil
      end
    end
  end

  def require_login
    #debugger

    if session[:logged_in]
      begin
        @_USER = Account.find(session[:user_id])
        @_MAIN_CHAR = @_USER.main_character
        @_GUILD = @_USER.guild # If they are a guild owner this picks it up even without any chars created.
        @_GUILD = @_MAIN_CHAR.guild if (@_GUILD.nil? && !@_MAIN_CHAR.nil?) # This should pick up the guild for non-owners

        set_time_zone

        # If they haven't yet verified their email address and they are past
        # the expiration date, force them to verify their email address now.
        if @_USER.is_verified? != true
          if @_USER.email_verify_before < Time.new
            flash[:error] = "You must verify your account email address to continue."
            redirect_to confirm_account_url and return
          end
        end

        if @_GUILD
          # If they are trying to access a url for a guild other than the
          # one they are logged in to, redirect to the login page for the
          # guild they put in the URL.
          if (!current_subdomain.blank? && (current_subdomain != @_GUILD.subdomain))
            redirect_to login_url(:subdomain => current_subdomain) and return
          end
        else
          # If they are not in a guild and they have a subdomain entered,
          # redirect them to their account page with the subdomain removed.
          unless current_subdomain.blank?
            redirect_to account_url(:subdomain => false) and return
          end
        end
      rescue
        session[:logged_in] = false
        session[:user_id] = nil

        redirect_to login_url and return
      end
    else
      redirect_to login_url and return
    end
  end

  def set_time_zone
    Time.zone = @_USER.time_zone and return unless @_USER.blank? or @_USER.time_zone.blank?
    Time.zone = @_GUILD.guild_config.default_time_zone and return unless @_GUILD.blank? or @_GUILD.guild_config.blank? or @_GUILD.guild_config.default_time_zone.blank?
    Time.zone = 'Pacific Time (US & Canada)'
  end


  def require_guild
    redirect_to account_url(:subdomain => false) if @_GUILD.nil?
  end

  def ensure_current_user_owns_character(char)
    unless char.account == @_USER
      flash[:error] = "The character you attempted to modify is not part of your account."
      redirect_to account_url and return
    end
  end

  def update_character_filters(filters)
  	if filters.blank?
    	session[:char_filters] = { :char_class => { :deathknight => true, :druid => true, :hunter => true, :mage => true, :paladin => true, :priest => true, :rogue => true, :shaman => true, :warlock => true, :warrior => true }, :char_role => {} }
  	else
	    session[:char_filters] = { :char_class => {}, :char_role => {} }

	    unless filters[:char_class].blank?
	      filters[:char_class].each do |key, value|
	        session[:char_filters][:char_class][key.to_sym] = true
	      end
	    end

	    unless filters[:char_role].blank?
	      filters[:char_role].each do |key, value|
	        session[:char_filters][:char_role][key.to_sym] = true
	      end
	    end
		end
  end
end
