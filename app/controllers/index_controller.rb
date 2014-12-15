class IndexController < ApplicationController
 protect_from_forgery with: :null_session
# before_filter :authenticate_user!

  def index
  	if user_signed_in?
    #CAUTIONNNNNNNN ::::   change to devise parameters later #####
    # Password fields present on an insecure (http://) page. This is a security risk that allows user login credentials to be stolen.[Learn More]
    # Password fields present in a form with an insecure (http://) form action. This is a security risk that allows user login credentials to be stolen.[Learn More]
  	# when notification comes for the first time it shows a undefined .... preload a data in advance##################################################
  	# channel communication gets criss crossed in show and stock ############################################################################################
    # fix multiple binding ###############################################################################
  		 @user = User.find(current_user)
         redirect_to :controller=>'dalal_dashboard', :action=>'show', :id => current_user.id
  	end	   
  end
end
