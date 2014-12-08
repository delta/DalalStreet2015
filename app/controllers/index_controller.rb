class IndexController < ApplicationController
 protect_from_forgery with: :null_session
# before_filter :authenticate_user!

  def index
  	if user_signed_in?
    #caution ::::   change to devise parameters later #####
  		 @user = User.find(current_user)
  		 redirect_to :controller=>'dalal_dashboard', :action=>'show', :id => current_user.id
  	end	   
  end
end
