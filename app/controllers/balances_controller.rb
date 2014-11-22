class BalancesController < ApplicationController

  before_filter :require_login

  def index
    @balance_accounts = @_GUILD.balance_accounts.with_balances_for_character(@_MAIN_CHAR.id).find(:all, :order => 'name ASC')
  end
  
  def show
    @ba = @_GUILD.balance_accounts.find(params[:id])
    #@ba = @_GUILD.balance_accounts.find(params[:id])
  end
  
  def history
    @ba = @_GUILD.balance_accounts.find(params[:balance_id])
    @char = @_GUILD.characters.find(params[:char_id])
    @char_bal = @ba.character_balances.find(:first, :conditions => ["character_id = ?", @char.id])
    @transactions = @char_bal.balance_transactions.find(:all, :order => "created_at DESC", :limit => 30)
  end

  def filter
    ba = @_GUILD.balance_accounts.find(params[:id])
    update_character_filters(params[:filter])
    redirect_to balance_url(:id => ba.id)
  end
  
end
