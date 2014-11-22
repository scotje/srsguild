require 'digest/sha1'

class Account < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :time_zone, :mobile_number
  
  has_one :guild, :foreign_key => 'owner_id'

  has_one :main_character, :class_name => "Character", :conditions => "is_main = 1"
  has_many :alt_characters, :class_name => "Character", :conditions => "is_main = 0"
  has_many :characters
  
  has_many :calendar_events
  
  attr_accessor :password, :password_confirmation, :skip_email_validation, :request_host
  
  validates_presence_of :email
  validates_presence_of :pw_hash
  validates_presence_of :pw_salt
  
  validates_uniqueness_of :email
  validates_uniqueness_of :email_verification_value, :allow_nil => true
  
  validates_confirmation_of :password
  
  validates_format_of :mobile_number, :with => /[0-9]*/, :allow_nil => true
  validates_length_of :mobile_number, :within => 10..15, :allow_nil => true

  before_validation :hash_password!
  before_validation :clean_mobile_number!
  
  after_create :verify_email
  
  def self.login(email, password)
    user = self.find(:first, :conditions => ["email = ? AND pw_hash = SHA1(CONCAT(?, pw_salt))", email, password])
    
    if user.nil?
      raise ZguildError::LoginFailed.new
    else
      user
    end
  end
  
  def is_verified?
    return (self[:email_verification_value].nil? and self[:email_verify_before].nil?)
  end
  
  def sms_enabled?
    return !self.mobile_number.blank?
  end

  def verify_email
    return if self.skip_email_validation == true
    
    self[:email_verification_value] = rand_str(6).upcase
    self[:email_verify_before] = Time.new + 7.days
    
    if self.valid?
      self.save
    elsif ((self.errors.size == 1) and (self.errors[:email_verification_value] != nil))
      while (self.invalid?) do
        self[:email_verification_value] = rand_str(6).upcase
      end
      
      self.save
    end
    
    Srsmailer.deliver_account_create_verify(self, self.request_host)
    
    return true
  end
  
  protected
  # -------------------------------------------
  
  def hash_password!
    unless password.nil?
      generate_salt! if pw_salt.nil?
      
      self.pw_hash = Digest::SHA1.hexdigest("#{password}#{pw_salt}")
    end
  end
  
  def generate_salt!
    self.pw_salt = Digest::SHA1.hexdigest(Time.now.to_s + rand(100000000).to_s)[1..20]
  end
  
  def clean_mobile_number!
    unless self.mobile_number.nil?
      self.mobile_number = self.mobile_number.gsub(/[^0-9]/, '')
    end
  end
end
