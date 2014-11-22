class Realm < ActiveRecord::Base

  named_scope :game, lambda { |game| 
    { :conditions => { :game => game } } unless game.blank?
  }
  

  named_scope :region, lambda { |region| 
    { :conditions => { :region => region } } unless region.blank? or region == 'any'
  }

  named_scope :subregion, lambda { |subregion| 
    { :conditions => { :subregion => subregion } } unless subregion.blank? or subregion == 'any'
  }
  
  named_scope :realm_type, lambda { |realm_type| 
    { :conditions => { :realm_type => realm_type } }unless realm_type.blank? or realm_type == 'any'
  }
 
end
