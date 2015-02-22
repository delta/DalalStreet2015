  class CustomRedirection < Devise::FailureApp

    def redirect_url
     redirect_to :controller => 'index'
    end
    
    def respond
      if http_auth?
        http_auth
      else
        redirect
      end
    end

  end