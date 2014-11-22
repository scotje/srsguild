class BalanceTransaction < ActiveRecord::Base
  belongs_to :character_balance
  belongs_to :calendar_event

  validates_presence_of :character_balance
  validates_presence_of :adjustment
  validates_numericality_of :adjustment
end
