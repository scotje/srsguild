class Admin::RosterController < Admin::AdminController
  
  def index
    if params[:search]
      # This is used for an AJAX call.
      @characters = @_GUILD.main_characters.find(:all, :conditions => ["name LIKE ?", "%#{params[:search]}%"], :order => "name ASC")
    else
      @characters = @_GUILD.main_characters.find(:all, :order => "FIELD(guild_role, 'Alt', 'Initiate', 'Member', 'Core', 'Officer', 'Leader') DESC, name ASC")
    end
  end
  
  def update_all
    unless params[:characters].blank?
      params[:characters].each do |char_id, settings|
        unless settings.blank?
          c = @_GUILD.main_characters.find(char_id.to_i)
          
          c.guild_role = (settings[:guild_role].blank?) ? nil : settings[:guild_role]

          if ((@_GUILD.owner == @_USER) and (@_CHAR != c))
            c.is_admin = (settings[:admin]) ? true : false
          end
          
          c.save!
        end
      end
    end
    
    redirect_to admin_roster_index_url and return
  end
  
  def create_sms
    @recipient = @_GUILD.main_characters.find(params[:id])
    @credits_left = 25
  end
  
  def send_sms
    recipient = @_GUILD.main_characters.find(params[:id])
    
    begin
      sms_params = { 'From' => '4155992671', 'To' => recipient.account.mobile_number.to_s, 'Body' => params[:message_body].strip, 'StatusCallback' => 'http://srsguild.com/twilio_test' }
      account = Twilio::RestAccount.new(TWILIO_ACCOUNT_SID, TWILIO_ACCOUNT_TOKEN)
      resp = account.request("/#{TWILIO_REST_API_VERSION}/Accounts/#{TWILIO_ACCOUNT_SID}/SMS/Messages", 'POST', sms_params)
      resp.error! unless resp.kind_of? Net::HTTPSuccess
    rescue StandardError => bang
      flash[:error] = "Error #{bang}"
      redirect_to :action => 'create_sms' and return
    end
    
    # Log the message for auditing purposes.
    log = SmsSentLog.new
    log.sent_by = @_USER.id
    log.from_guild = @_GUILD.id
    log.sent_to = "#{recipient.account.mobile_number} (#{recipient.account.id})"
    log.message_length = params[:message_body].strip.size
    log.save
    
    flash[:notice] = "SMS Sent"
    redirect_to :action => 'index' and return
  end
  
  def gkick
    char = @_GUILD.main_characters.find(params[:id])
    
    if ((@_GUILD.owner == char.account) or char.is_admin)
      flash[:error] = "You can't gkick that person."
    else
      char.withdraw
      flash[:notice] = "That character has been removed from the guild."
    end
    
    redirect_to admin_roster_index_url and return
  end
end
