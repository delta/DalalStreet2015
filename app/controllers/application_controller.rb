class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception

  def index

  end

   # def set_locale
   #    I18n.locale = params[:locale]
   #  end

   #  def self.default_url_options(options={})
   #    options.merge({ :locale => I18n.locale })
   #  end
   
  protected
  def configure_devise_permitted_parameters
    registration_params = [:id, :username, :email, :password, :password_confirmation]

    if params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) { 
        |u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.for(:sign_up) { 
        |u| u.permit(registration_params) 
      }
    end
  end
  
end
