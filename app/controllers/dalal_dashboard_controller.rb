class DalalDashboardController < ApplicationController
before_filter :authenticate_user! #devise filters#
protect_from_forgery with: :null_session

require "json"

layout "../dalal_dashboard/layout/layout.html.erb"

	def index
		if user_signed_in?
         #caution ::::   change to devise parameters later #####
         #######.................redirect to main page if user not valid ..............instead it is redirecting now to /user/sign_in...which is not correct
  		 @user = User.find(current_user)
  		 redirect_to :controller=>'dalal_dashboard', :action=>'show', :id => current_user.id
  		else
  		 redirect_to :action => 'index'	
  		end 	
	end
	
	def show
		if request.get?
		   if !user_signed_in?
	         redirect_to :action => 'index'
	       else
	       	  @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	          @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id).group("stock_id")
	          ##create methos to get the total stock price of the user#############
              #######################
	       end
	    else
	       ##fill up

	    end   
	end


 	def stock
	       if user_signed_in?
	        	@stocks = Stock.all
	        	@user_cash_inhand = User.find(current_user.id)
	        	@extra = @user_cash_inhand.cash
	        	@notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	        	##create methos to get the total stock price of the user#############
	       else
	          redirect_to :action => 'index'
	       end	   
    end #stock def

    def buy_sell_page
    
	    if user_signed_in?
             
	    	   @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id).group("stock_id")
	           @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	           logger.info @stocks[0].stockname
	          ##create methos to get the total stock price of the user#############
              #######################
	    else
	       redirect_to :action => 'index'
	    end

    end ####end of buy def

protected

    def comparator 
    	
    

    end ##end of comparator

########################IMPORTANT :::::: Dont forget to block url to http://0.0.0.0:3000/dalal_dashboard/298486374/buy_sell_stock :::::####################################
    def buy_sell_stock
      if request.get?
    	
    	if user_signed_in?
                ##@stock_unique = Stock.find(:all, :conditions => ["stockname = ?", params[:stockname]])
                 #@stock_unique = Stock.find_by_stockname(params[:stockname])
	    	   @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.stockname' => params[:stockname] ).group("stock_id")
	           @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
               logger.info @stocks[0].stockname 
               ##create methods to get the total stock price of the user#############
              #######################
	    else
	       redirect_to :action => 'index'
	    end

	  else
	  	
	  	if user_signed_in?
	  		## to check post from which form
	  		logger.info params[:identity_buy]

	  		 if params[:identity_buy]
	  		    @stockid = params[:identity_buy].split("_")[1]
                @numofstock_buy_for = params[:num_of_stock]
                @bid_price = params[:buy]
                @stock = Stock.find(@stockid)
                @user_cash_inhand = User.find(current_user.id)
             
                if @stock.stocksinmarket.to_f > @numofstock_buy_for.to_f
	                if @user_cash_inhand.cash.to_f > @numofstock_buy_for.to_f*@bid_price.to_f 
		                @buy_bid = Buy.create(:user_id=>current_user.id, :stock_id=>@stockid, :price=>@bid_price, :numofstock=>@numofstock_buy_for)
		                flash[:notice] = "Successful Bid."
                        @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                        comparator
		                redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'buy_sell_page'
	                else
	                	flash[:error] = "Buy request failed.You only have $ #{@user_cash_inhand.cash}."
                        @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                        redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'buy_sell_page'
	                end
	            else
	            	flash[:error] = "Buy request failed.There are only #{@stock.stocksinmarket} stocks in the market."
                    @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
	                redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'buy_sell_page'
	            end

	  		 elsif params[:identity_sell]
	  		    @stockid = params[:identity_sell].split("_")[1]
                @numofstock_sell_for = params[:num_of_stock]
                @ask_price = params[:sell]
                @user_stock_inhand = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.id' => @stockid ).group("stock_id")
                
                if @user_stock_inhand[0].totalstock.to_f > @numofstock_sell_for.to_f
                	@sell_ask  = Sell.create(:user_id=>current_user.id, :stock_id=>@stockid, :priceexpected=>@ask_price, :numofstock=>@numofstock_sell_for)
               	 	flash[:notice] = "Sell request made."
               	 	@notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                	comparator
                	redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'buy_sell_page'
                else
                	flash[:error] = "Sell request failed.You only have #{@user_stock_inhand[0].totalstock} stocks of #{@user_stock_inhand[0].stockname}."
                    @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
              		redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'buy_sell_page'
                end
             else
               flash[:error] = "Did Not receive request.Please try again."
               @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
               redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'buy_sell_page'     		
	  		 end
	  		   
        else
           redirect_to :action => 'index'
        end	

	  end ##block for get or post request 
    end ####end of buy def


end  #class def  
