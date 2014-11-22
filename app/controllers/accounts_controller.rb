class AccountsController < ApplicationController
  
  before_filter :require_login, :except => [:new, :create, :confirm, :resend_confirmation, :verify, :forgot, :remind, :new_password, :reset_password]
  
  def show
    @account = @_USER
    @main_char = @account.main_character
    @alts = @account.alt_characters.find(:all, :order => 'name')
  end
  
  def new
    if flash[:new_account].blank?
      @account = Account.new
    else
      @account = Account.new(flash[:new_account])
    end
    
    unless current_subdomain.blank?
      @guild = Guild.find_by_subdomain(current_subdomain)
      redirect_to new_account_url(:subdomain => false) and return if @guild.nil?
      
      if flash[:new_character].blank?
        @character = Character.new
        @character.region = @guild.region
        @character.realm = @guild.realm
      else
        @character = Character.new(flash[:new_character])
      end

      @extended_fields = true if flash[:armory_error]
    end
  end
  
  def create
    Account.transaction do
      acct = Account.new(params[:account])
  		acct.request_host = request.host
  		acct.skip_email_validation = true unless current_subdomain.blank?

      if acct.save
        session[:logged_in] = true
        session[:user_id] = acct.id
      
        if (RAILS_ENV == 'development' and ['127.0.0.1', '::1'].include?(request.remote_ip))
          # Automatically confirm the account since it was created locally.
          acct.email_verification_value = nil
          acct.email_verify_before = nil
          acct.save!
        end
        
        unless current_subdomain.blank?
          guild = Guild.find_by_subdomain(current_subdomain)
          raise ActiveRecord::Rollback if guild.nil?

          if params[:guild_join_code].strip == guild.join_code
            char = Character.new(params[:character])
            char.account = acct
            char.guild = guild
            char.is_main = true
            char.guild_role = 'Initiate'

            if char.valid?
              char.save!

              acct.skip_email_validation = false
              acct.verify_email

              redirect_to success_account_url and return
            elsif char.errors.on_base.include?("armory_update_error")
              flash[:new_account] = params[:account]
              flash[:new_character] = params[:character]
              flash[:armory_error] = true

              raise ActiveRecord::Rollback
            else
              flash[:error] = "Whoops! Something was wrong with the character information you provided."
              flash[:errors] = char.errors
              flash[:new_account] = params[:account]
              flash[:new_character] = params[:character]

              raise ActiveRecord::Rollback
            end
          else
            flash[:error] = "The guild join code you provided was incorrect. Please check with your guild leaders for the correct code."
            flash[:new_account] = params[:account]
            flash[:new_character] = params[:character]

            raise ActiveRecord::Rollback
          end
        end

        redirect_to success_account_url and return
      else
        flash[:error] = "Whoops! Something was wrong with the new account information you provided."
        flash[:errors] = acct.errors
        
        raise ActiveRecord::Rollback
      end
    end
    
    redirect_to new_account_url
  end
  
  def update
    acct = @_USER
    
    params[:account][:password] = nil if params[:account][:password].blank?
    params[:account][:password_confirmation] = nil if params[:account][:password].blank?
    
    params[:account][:time_zone] = nil if params[:account][:time_zone].blank?
    
    acct.attributes = params[:account]
    
    if acct.save
      flash[:notice] = "Your account was successfully updated."
      redirect_to account_url and return
    else
      flash[:error] = "The new information you supplied for your account was not valid.<br /> If you are updating your password, please make sure both fields match."
      redirect_to account_url and return
    end
  end
  
  def success
  end
  
  def confirm
  end
  
  def resend_confirmation
    acct = Account.find(:first, :conditions => ["email = ? AND email_verification_value IS NOT NULL", params[:verify_email]])
    
    if acct != nil
      Srsmailer.deliver_account_create_verify(acct)
      flash[:notice] = "A new verification message has been sent."
    else
      flash[:error] = "No unverified account was found with that email address."
    end

    redirect_to confirm_account_url and return
  end
  
  def verify
    acct = Account.find(:first, :conditions => ["email_verification_value = ?", params[:verification_value].strip])
    
    if acct != nil
      acct.email_verification_value = nil
      acct.email_verify_before = nil
      acct.save!
      
      flash[:notice] = "Your email address has been verified! Please log in to continue."
      redirect_to login_url and return
    else
      flash[:error] = "Unable to find an account to verify using that code.<br />Perhaps you already verified your account?"
      redirect_to confirm_account_url and return
    end
  end
  
  def verify_manual
    verify
  end
  
  def forgot
    @email = flash[:email] if flash[:email]
  end
  
  def remind
    acct = Account.find(:first, :conditions => { :email => params[:email] })
    
    if acct.nil?
      flash[:error] = "Sorry, we were unable to find an account with that email address."
      flash[:email] = params[:email]
    else
      acct.password_reset_value = rand_str(16).upcase
      acct.password_reset_request_at = Time.new
      acct.password_reset_ip = request.ip
      
      acct.save!
      
      Srsmailer.deliver_account_password_reset_request(acct, request.host)
      
      flash[:notice] = "Reset email sent, please allow a few minutes for delivery."
    end
    
    redirect_to forgot_account_url and return
  end
  
  def new_password
    if params[:reset_code].blank?
      flash[:error] = "The reset code provided was invalid. Please try again or contact support."
      redirect_to forgot_account_url and return
    end
    
    @account = Account.find_by_password_reset_value(params[:reset_code])
    
    if (@account.nil? or (@account.password_reset_request_at < (Time.new - 1.days)))
      flash[:error] = "The reset code provided was invalid. Please try again or contact support."
      redirect_to forgot_account_url and return
    end
  end
  
  def reset_password
    if params[:reset_code].blank?
      flash[:error] = "The reset code provided was invalid. Please try again or contact support."
      redirect_to forgot_account_url and return
    end
    
    acct = Account.find_by_password_reset_value(params[:reset_code])
    
    if (acct.nil? or (acct.password_reset_request_at < (Time.new - 1.days)))
      flash[:error] = "The reset code provided was invalid. Please try again or contact support."
      redirect_to forgot_account_url and return
    end
    
    acct.password = params[:new_password]
    acct.password_confirmation = params[:new_password_confirmation]
    
    if acct.save
      acct.password_reset_value = nil
      acct.password_reset_request_at = nil
      acct.password_reset_ip = nil
      acct.save!
      
      flash[:notice] = "Your password was successfully updated. Go ahead and log in now!"
      redirect_to login_url and return
    else
      flash[:error] = "The password and password confirmation field did not match, please try again. Type carefully this time."
      redirect_to :action => 'new_password', :reset_code => params[:reset_code] and return
    end
  end
end
