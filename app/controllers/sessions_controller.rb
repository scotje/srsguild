class SessionsController < ApplicationController
  layout false

  def new
    unless current_subdomain.blank?
      @guild = Guild.find_by_subdomain(current_subdomain)
      
      redirect_to login_url(:subdomain => false) if @guild.nil?
    end
  end

  def create
    begin
      user = Account::login(params[:email], params[:password])
      
      reset_session
      
      session[:logged_in] = true
      session[:user_id] = user.id
      session[:admin_auth_at] = Time.new
      
      if params[:for_admin]
        redirect_to admin_dashboard_url and return
      end
      
      if user.main_character && user.main_character.guild
        redirect_to guild_url(:subdomain => user.main_character.guild.subdomain) and return
      else
        redirect_to account_url and return
      end
    rescue ZguildError::LoginFailed
      flash[:error] = "Ooops! The e-mail address or password you entered doesn't match what we have on file. <a href=\"#{forgot_account_path}\">Did you forget your password?</a>"

      if params[:for_admin]
        redirect_to login_url, :for_admin => true and return
      else
        redirect_to login_url and return
      end
    end
  end
  
  def destroy
    session[:logged_in] = false
    
    if current_subdomain.blank?
      redirect_to root_url(:subdomain => false)
    else
      redirect_to login_url(:subdomain => current_subdomain)
    end
  end
  

end
