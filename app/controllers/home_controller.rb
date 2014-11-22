class HomeController < ApplicationController

  before_filter :check_login
  
  def index
    #redirect_to :controller => '/guild' and return if @_GUILD
    #redirect_to accounts_url and return if @_USER
    
    @header_bonus_template = 'home/index_header_bonus' unless @_USER
  end
  
  def tour
  end

  def pricing
  end
  
  def contact
    @from_email = flash[:from_email] if flash[:from_email]
    @message = flash[:message] if flash[:message]
  end
  
  def contact_submit
    redirect_to contact_url unless request.post?
    
    if params[:from_email].blank? or params[:message].blank?
      flash[:from_email] = params[:from_email]
      flash[:message] = params[:message]
      flash[:error] = "Please complete all fields and submit your message again."
    else
      if Srsmailer.deliver_contact_form(params[:from_email], params[:message])
        flash[:notice] = "Your message has been sent. Thanks!"
      else
        flash[:error] = "Whoops, there was a problem sending your message. Sorry! Try sending an email instead."
      end
    end
    
    redirect_to contact_url and return
  end
  
  def security
  end
end
