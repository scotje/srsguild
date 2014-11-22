class Backend::BackendController < ApplicationController
  before_filter :authenticate
  
  layout 'backend'
  
  private
  #--------------------------------------------------------------------------
  USER_ID, PASSWORD = "manage", "7f3e8f62b"
  
  def authenticate
    authenticate_or_request_with_http_basic do |id, password| 
        id == USER_ID && password == PASSWORD
    end
  end
end
