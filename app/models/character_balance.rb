class CharacterBalance < ActiveRecord::Base
  belongs_to :character
  belongs_to :balance_account
  
  has_many :balance_transactions
  
  validates_presence_of :character
  validates_presence_of :balance_account
  validates_presence_of :balance
  validates_numericality_of :balance
  
  def adjust_balance!(adjustment, adjuster=nil, options=nil)
    adj_operator, adj_amt = adjustment.match(/^(\+|-|=)?(\d+\.?\d*)$/).to_a[-2,2]

    # Make sure the adjustment amount is a sane number (it matched the Regex group)
    return if adj_amt.nil?
    
    self.transaction do
      case adj_operator
        when "=" then new_balance = adj_amt.to_f
        when "-" then new_balance = self.balance - adj_amt.to_f
        else new_balance = self.balance + adj_amt.to_f
      end
      
      BalanceTransaction.transaction do
        bt = BalanceTransaction.new
        bt.character_balance = self
        bt.previous_balance = self.balance
        bt.adjustment = new_balance - self.balance
        bt.modified_by = adjuster unless adjuster.nil?
        bt.comment = options[:comment] unless options.nil? or options[:comment].blank?
        bt.calendar_event_id = options[:calendar_event_id] unless options.nil? or options[:calendar_event_id].blank?

        bt.save!
      
        self.balance = new_balance
        self.save!
        
        if (self.balance_account.zero_sum?) and (bt.adjustment != 0.0)
          raise ActiveRecord::Rollback.new("Adjustments cannot be made to a zero sum account without at least one counterparty.") if options[:counterparties].blank?
          
          counterparties = CharacterBalance.find(:all, :conditions => ["balance_account_id = ? AND character_id IN (?) AND character_id != ?", self.balance_account.id, options[:counterparties], self.character.id])
          
          cp_adjustment = (((bt.adjustment / counterparties.size)*100).round / 100.0) * -1.0
          
          counterparties.each do |cp|
            cp_bt = BalanceTransaction.new
            cp_bt.character_balance = cp
            cp_bt.previous_balance = cp.balance
            cp_bt.adjustment = cp_adjustment
            cp_bt.modified_by = adjuster unless adjuster.nil?
            cp_bt.comment = "#{options[:comment]} " unless options.nil? or options[:comment].blank?
            cp_bt.comment = "#{cp_bt.comment}(Maintaining zero sum.)"
            cp_bt.calendar_event_id = options[:calendar_event_id] unless options.nil? or options[:calendar_event_id].blank?
          
            cp_bt.save!
          
            cp.balance = cp.balance + cp_adjustment
            cp.save!
          end
        end
      end
    end
  end
end
