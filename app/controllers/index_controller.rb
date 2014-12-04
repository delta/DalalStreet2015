class IndexController < ApplicationController
  def index
  	if user_signed_in?
    #caution ::::   change to devise parameters later #####
  		 @user = User.find(current_user)
  		 redirect_to :controller=>'dalal_dashboard', :action=>'show', :id => current_user.id
  	end	   
  end
end
