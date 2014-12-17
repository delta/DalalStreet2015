class DalalDashboardController < ApplicationController
before_filter :authenticate_user! #devise filters#
protect_from_forgery with: :null_session

require "json"

 before_filter :set_cache_buster
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

layout "../dalal_dashboard/layout/layout.html.erb"

	def index
		if user_signed_in?
         #caution ::::   change to devise parameters later #####
         #######.................redirect to main page if user not valid ..............instead it is redirecting now to /user/sign_in...which is not correct
  		 #######....Wats the limit of stocks user can buy from stocksinmarket,,how much he can bid for etc.........###########################
  		 #######....wat to do if sum of total stock is zero in stock_useds ..........................#########################
  		 @user = User.find(current_user)
  		 redirect_to :controller=>'dalal_dashboard', :action=>'show', :id => current_user.id
  		else
  		 redirect_to :action => 'index'	
  		end 	
	end
	
	def show
		## the chart and pie charts fix em .........works only on reload ...... #####################
		if request.get?
		   if !user_signed_in?
	         redirect_to :action => 'index'
	       else
	       	  @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	       	  @stocks = Stock.return_bought_stocks(current_user.id)
	          @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	       end
	    else
	       ##fill up

	    end   
	end

 	def stock
	       if user_signed_in?
                Stock.connection.clear_query_cache
	        	@stocks = Stock.all
	        	@notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	            @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	       else
	          redirect_to :action => 'index'
	       end	   
    end #stock def

    def buy_sell_page
    
	    if user_signed_in?
	    	  #@stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => current_user.id).group("stock_id")
	           @stocks_list = Stock.all
	           @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	           @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	    else
	       redirect_to :action => 'index'
	    end

    end ####end of buy def

########################IMPORTANT :::::: Dont forget to block url to http://0.0.0.0:3000/dalal_dashboard/298486374/buy_sell_stock :::::####################################
    def buy_sell_stock
      if request.get? 	
    	if user_signed_in?
            @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.stockname' => params[:stockname] ).group("stock_id").first
	        @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	        @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
            if !@stocks
              @stocks = Stock.select("stocks.*").where('stocks.stockname' => params[:stockname]).first
              @No_stock_found = "You do not own Stocks belonging to this Company.To buy stocks send a bid request first."
            end   
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
                        ## call comparator ##can be made efficient
                        @comparator = User.comparator(params[:identity_buy].split("_")[0])
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
                    ## call comparator ##can be made efficient
                	@comparator = User.comparator(params[:identity_sell].split("_")[0])
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

    
    def bank_mortgage
    	 if user_signed_in?
	       	   @stocks_list = Stock.return_bought_stocks(current_user.id)
	           @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	           @notifications_list = Notification.get_notice(current_user.id,10)
	     else
	       redirect_to :action => 'index'
	     end
    end ###bank_mortgage

    def bank_mortgage_stock
    	if request.get?
	    	if user_signed_in?
	          @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.stockname' => params[:stockname] ).group("stock_id").first
	          @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	          @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	    	else
	    	  redirect_to :action => 'index'
	    	end
	    else
	    	if user_signed_in?
	    		@stockid = params[:identity_bank].split("_")[1]
                @numofstock_to_mortgage = params[:num_of_stock]
	            @check_stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.id' => @stockid ).group("stock_id").first
                logger.info @check_stock.totalstock 
                ##check if he has enough stock
                if @check_stock.totalstock.to_f >= @numofstock.to_f
                   @user_cash_inhand = User.find(current_user.id)
                   @user_cash_inhand.cash = @user_cash_inhand.cash.to_f + 0.75*@numofstock_to_mortgage.to_f*@check_stock.currentprice.to_f
                   @stockused = StockUsed.create(:user_id => current_user.id, :stock_id => @stockid,:numofstock => -1*@numofstock_to_mortgage.to_f)
                   @mortgage = Bank.create(:user_id => current_user.id, :stock_id => @stockid,:pricerendered => @check_stock.currentprice, :numofstock => @numofstock_to_mortgage)
                   @user_cash_inhand.save  
                   @extra_cash = 0.75*@numofstock_to_mortgage.to_f*@check_stock.currentprice.to_f
                   flash[:notice] = "Mortgage Successful.$#{@extra_cash} added to your account"
                   @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
              	   redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                else
                   flash[:error] = "Invalid request.You only have #{@check_stock.totalstock} stocks of #{@check_stock.stockname}."
                   @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
              	   redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                end
	    	else
	    	  redirect_to :action => 'index'
	    	end ##end of user_signed_in
	    end ##end of request
    end##end of bank_mortgage

	def buy_sell_history
        if user_signed_in?
        	@buy_history = Buy.select("stock_id,numofstock,updated_at,price").where('user_id' => current_user.id).last(10).reverse
        	@sell_history = Sell.select("stock_id,numofstock,updated_at,priceexpected").where('user_id' => current_user.id).last(10).reverse
	        @notifications_list = Notification.get_notice(current_user.id,10)
	        @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
        else
        	redirect_to :action => 'index'
        end
	end

    def company
    	if user_signed_in?
	        @notifications_list = Notification.get_notice(current_user.id,10)
	        @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	    else
	      redirect_to :action => 'index'
	    end

    end
    def market_events
        if user_signed_in?
           # @stocks_list = Stock.return_bought_stocks(current_user.id)
	       # @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
	       # @notifications_list = Notification.get_notice(current_user.id,10)
	        
           
        else
            redirect_to :action => 'show'
        end
    end 

end  #class def  
