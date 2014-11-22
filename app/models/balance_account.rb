class BalanceAccount < ActiveRecord::Base
  attr_accessible :name, :account_type, :decay_percent

  belongs_to :guild
  has_many :character_balances, :dependent => :delete_all
  has_many :characters, :through => :character_balances
  has_many :characters_with_balance, :class_name => "Character", :through => :character_balances, :source => :character, :select => "characters.id, characters.name, characters.character_class, character_balances.balance, character_balances.updated_at"
  
  
  validates_presence_of :guild
  validates_presence_of :name
  validates_inclusion_of :account_type, :in => %w( standard zero_sum suicide_kings )
  validates_numericality_of :decay_percent, :allow_nil => true
  
  named_scope :with_balances_for_character, lambda { |char_id| 
    {
      :joins => "LEFT JOIN character_balances ON (character_balances.balance_account_id = balance_accounts.id AND character_balances.character_id = #{char_id})", 
      :select => "balance_accounts.*, character_balances.balance AS balance"
    }
  }
  
  def zero_sum?
    return self.account_type == 'zero_sum'
  end
  
  def last_modified_date
    newest_balance = self.character_balances.find(:first, :order => "updated_at DESC")
    
    return newest_balance.nil? ? nil : newest_balance.updated_at
  end
  
  def filtered_characters(filters)
    self.characters.find(:all, :conditions => Character.find_filters(filters))
  end
  
  def filtered_characters_with_balance(filters, order_by = "balance DESC, name ASC")
    self.characters_with_balance.find(:all, :conditions => Character.find_filters(filters), :order => order_by)
  end

  def decay_balances!
    decay_factor = 1.0 - (self.decay_percent.to_f / 100)

    self.transaction do
      self.character_balances.each do |cb|
        new_balance = (((cb.balance * decay_factor) * 100).round) / 100.0
        
        bt = BalanceTransaction.new
        bt.character_balance = cb
        bt.previous_balance = cb.balance
        bt.adjustment = new_balance - cb.balance
        bt.modified_by = "[SYSTEM]"
        bt.comment = "Automatic weekly balance decay."

        bt.save!
      
        cb.balance = new_balance
        cb.save!
      end
    end
    
    self.last_decayed_at = Time.new
    self.save!
    
    return true
  end
  
  # Weekly balance decay.
  def self.decay_all_accounts!
    BalanceAccount.find(:all, :conditions => "decay_percent > 0 AND ((last_decayed_at IS NULL) OR (last_decayed_at < DATE_ADD(NOW(), INTERVAL -7 DAY)))").each do |ba|
      ba.decay_balances!
    end
    
    return true
  end
end
