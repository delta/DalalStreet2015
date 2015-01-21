class IndexController < ApplicationController
protect_from_forgery with: :null_session
# before_filter :authenticate_user!
include IndexHelper
  def index
    #CAUTIONNNNNNNN ::::   change to devise parameters later #####
    # Password fields present on an insecure (http://) page. This is a security risk that allows user login credentials to be stolen.[Learn More]
    # Password fields present in a form with an insecure (http://) form action. This is a security risk that allows user login credentials to be stolen.[Learn More]
    # when notification comes for the first time it shows a undefined .... preload a data in advance##################################################
    # fix multiple binding ###############################################################################
    # fix the application.html.erb page also  .......####################  
    @stocks_list = Stock.all
    @market_events_paginate = MarketEvent.order('created_at DESC').limit(7).offset(0)
    @market_events_count = MarketEvent.count/7
    @stock_names = image_loader

    @i = 0;
        
  	if user_signed_in?
       @user = User.find(current_user)
       redirect_to :controller=>'dalal_dashboard', :action=>'show', :id => current_user.id
  	end
    	   
  end
end
