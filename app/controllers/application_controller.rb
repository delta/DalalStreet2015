class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index

  end

   # def set_locale
   #    I18n.locale = params[:locale]
   #  end

   #  def self.default_url_options(options={})
   #    options.merge({ :locale => I18n.locale })
   #  end
  
end
