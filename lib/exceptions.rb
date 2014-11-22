module ZguildError
  
  class ZguildError < StandardError
    def new
      super
    end
    
  end
  
  class LoginFailed < ZguildError
  end
end