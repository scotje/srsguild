class Admin::BalancesController < Admin::AdminController

  def index
    @balance_accounts = @_GUILD.balance_accounts.find(:all, :conditions => "active = 1", :order => "name ASC")
  end
  
  def show
    @ba = @_GUILD.balance_accounts.find(params[:id])
  end
  
  def filter
    @ba = @_GUILD.balance_accounts.find(params[:id])
    update_character_filters(params[:filter])
    #redirect_to edit_admin_balance_url(:id => params[:id])
    redirect_to :back
  end
  
  def new
    @balance_account = BalanceAccount.new
  end
  
  def create
    @new_account = BalanceAccount.new(params[:balance_account])
    @new_account.guild = @_GUILD
    @new_account.active = true

    if @new_account.save
      flash[:notice] = "New account created successfully."
    else
      flash[:error] = "Unable to create new account."
    end

    redirect_to admin_balances_url and return
  end
  
  def edit
    @balance_account = @_GUILD.balance_accounts.find(params[:id])

    @recent_events = @_GUILD.calendar_events.find(:all, :conditions => ["begins_at < ?", Time.new], :order => "begins_at DESC", :limit => 20)
    @selected_event_id = (session[:admin][:balances][@balance_account.id][:event] rescue nil)
    
    if @balance_account.zero_sum?
      @counterparties = (session[:admin][:balances][@balance_account.id][:counterparties] rescue Array.new)
    end
  end
  
  def update
    @balance_account = @_GUILD.balance_accounts.find(params[:id])
    
    unless params[:balance_account].blank?
      params[:balance_account].delete(:account_type) if params[:balance_account][:account_type]
      @balance_account.update_attributes(params[:balance_account])

      flash[:notice] = "Account properties updated."
    end
    
    unless params[:adjust].blank?
      unless params[:adjust_event].blank?
        evt = @_GUILD.calendar_events.find(params[:adjust_event])
        
        if evt
          evt_id = evt.id

          session[:admin] ||= {}
          session[:admin][:balances] ||= {}
          session[:admin][:balances][@balance_account.id] ||= {}
          session[:admin][:balances][@balance_account.id][:event] = evt.id
        end
      end
      
      params[:adjust].each do |char_id, adjustment|
        cb = CharacterBalance.find_or_initialize_by_balance_account_id_and_character_id(@balance_account.id, char_id.to_i)
        
        if @balance_account.zero_sum?
          cb.adjust_balance!(adjustment, @_MAIN_CHAR.name, { :comment => params[:adjust_comment], :calendar_event_id => evt_id, :counterparties => params[:counterparty].keys }) unless adjustment.blank?
          
          session[:admin] ||= {}
          session[:admin][:balances] ||= {}
          session[:admin][:balances][@balance_account.id] ||= {}
          session[:admin][:balances][@balance_account.id][:counterparties] = params[:counterparty].keys
        else
          cb.adjust_balance!(adjustment, @_MAIN_CHAR.name, { :comment => params[:adjust_comment], :calendar_event_id => evt_id }) unless adjustment.blank?
        end
      end

      flash[:notice] = "Account balances updated."
    end
    
    
    redirect_to edit_admin_balance_url(@balance_account) and return
  end
  
  def destroy
    balance_account = @_GUILD.balance_accounts.find(params[:id])
    balance_account.is_deleted = true
    balance_account.save!
    
    flash[:notice] = "Account deleted."
    redirect_to admin_balances_url
  end
  
  # AJAX methods
  
  def char_balance_row
    @char = Character.find_by_name(params[:character_name])
    @count = params[:count].to_i || ""
    @zero_sum = params[:zero_sum] == "true"

    if @char.nil?
      render :text => "Not found.", :status => :forbidden, :layout => false and return
    end
    
    exclude = JSON.parse(params[:exclude])
    
    if exclude.any? { |id| id.to_i == @char.id }
      render :text => "That person is already on the list!", :status => :forbidden, :layout => false and return
    end
    
    render :partial => 'char_balance_row', :layout => false
  end
end
