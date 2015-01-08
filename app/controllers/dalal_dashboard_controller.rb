class DalalDashboardController < ApplicationController
before_filter :authenticate_user!,:set_cache_buster #devise filters#
protect_from_forgery with: :null_session

include RemoteLinkRenderer
require "json"

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
  		 ########....................... current user cash doesnt get rendered all the time ............................##################
       ####### .................... add market capital to dalal and company page .....................#####################
       ###### ....... some webscokets dont run without the show page being loaded ...................##############
       ###### ...............remember to change active record gem sqlite file in server gem....................................#############
       ##### ................. cache important pages and minify assets ..................######################
       ####### localhost tester ..............find a plugin.............#####################################
       ######### check for null values and rows .......................##############################
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
            @stocks_list = Stock.all
	       	  @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(5).reverse
            
            @notifications_paginate = Notification.order('created_at DESC').limit(7).offset(0) 
            @notifications_count = Notification.count/7 
            @market_events_paginate = MarketEvent.order('created_at DESC').limit(7).offset(0)
            @market_events_count = MarketEvent.count/7
            
            @stocks = Stock.return_bought_stocks(current_user.id)
           if !@stocks.blank?
              @stock = @stocks[0]
              @stock_price = Stock.read_current_price(@stock.id)
              @market_event_list  = MarketEvent.get_events(7,@stocks[0].id)
              else
                @no_stock_found = "You have not bought any stocks yet"
	          end
            @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
            @mortgage = Stock.joins(:banks).select("*,banks.numofstock*stocks.currentprice as netcash").where("banks.user_id" => current_user.id).group("banks.id")
            if @mortgage.blank?
               @no_mortgage_found = "You have not mortgaged any stocks yet."
            end
            
            @news_feed = MarketEvent.first
            @class_show_active = "class=active"
         end
	    else
	       ##fill up

	    end   
	end

 	def stock
	       if user_signed_in?
            Stock.connection.clear_query_cache
	        	@stocks_list = Stock.all
	        	@notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	          @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
            @notifications_paginate = Notification.order('created_at DESC').limit(7).offset(0) 
            @notifications_count = Notification.count/7       
            @market_events_paginate = MarketEvent.order('created_at DESC').limit(7).offset(0)
            @market_events_count = MarketEvent.count/7
            @class_stock_active = "class=active"
         else
	          redirect_to :action => 'index'
	       end	   
    end #stock def

    def buy_sell_page
	    if user_signed_in?
             Stock.connection.clear_query_cache
	    	     @stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => current_user.id).group("stock_id").first
	           @stocks_list = Stock.all
	           @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
             @no_stock_found = nil
             @notifications_paginate = Notification.limit(7).offset(0) 
             @notifications_count = Notification.count/7     
             @market_events_paginate = MarketEvent.limit(7).offset(0)
             @market_events_count = MarketEvent.count/7
             @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
             @class_buy_sell_active = "class=active"
             @buy_history = Buy.select("stock_id,numofstock,price").where('stock_id' => @stock.id).last(3).reverse
             @sell_history = Sell.select("stock_id,numofstock,priceexpected").where('stock_id' => @stock.id).last(3).reverse
      else
	       redirect_to :action => 'index'
	    end
    end ####end of buy def

########################IMPORTANT :::::: Dont forget to block url to http://0.0.0.0:3000/dalal_dashboard/298486374/buy_sell_stock :::::####################################
    def buy_sell_stock
	  	if user_signed_in?
	  		 if params[:identity_buy]
	  		        @stockid = params[:identity_buy].split("_")[1]
                @numofstock_buy_for = params[:num_of_stock]
                @bid_price = params[:buy]
                @stock = Stock.find(@stockid) 
                @user_cash_inhand = User.find(current_user.id)
             
              if @stock.stocksinmarket.to_f >= @numofstock_buy_for.to_f
                 if @bid_price.to_f <= (0.1*@stock.currentprice.to_f+@stock.currentprice.to_f)
	                 if @user_cash_inhand.cash.to_f >= @numofstock_buy_for.to_f*@bid_price.to_f 
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
                  @max_bid_price = (0.1*@stock.currentprice.to_f+@stock.currentprice.to_f).round(2)
                  flash[:error] = "You cannot bid for more than 10% of the current price the max buy price for #{@stock.stockname} is #{@max_bid_price}."
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
                 
                if @user_stock_inhand[0].totalstock.to_f >= @numofstock_sell_for.to_f
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
    end ####end of buy def

    def bank_mortgage
    	 if user_signed_in?
	       	   @stocks_list = Stock.all
             @stocks = Stock.return_bought_stocks(current_user.id)
             @stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id).group("stock_id").first
	           @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
             @mortgage = Bank.where("banks.user_id" => current_user.id,"banks.stock_id" => @stock.id)
             
              @no_mortgage = nil
              if @mortgage.blank?
               @no_mortgage = "You have not mortgaged any stocks of #{@stock.stockname} yet."
              end
             
             @notifications_list = Notification.get_notice(current_user.id,10)
             @notifications_paginate = Notification.order('created_at DESC').limit(7).offset(0) 
             @notifications_count = Notification.count/7      
             @market_events_paginate = MarketEvent.order('created_at DESC').limit(7).offset(0)
             @market_events_count = MarketEvent.count/7
             @class_bank_active = "class=active"
       else
	       redirect_to :action => 'index'
	     end
    end ###bank_mortgage

    def bank_mortgage_stock
	    	if user_signed_in?
            if params[:identity_bank]
	    	      	@stockid = params[:identity_bank].split("_")[1]
                @numofstock_to_mortgage = params[:num_of_stock]
	              @check_stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.id' => @stockid ).group("stock_id").first
                if @check_stock.totalstock.to_f >= @numofstock_to_mortgage.to_f and @numofstock_to_mortgage.to_f>0
                   @user_cash_inhand = User.find(current_user.id)
                   @user_cash_inhand.cash = @user_cash_inhand.cash.to_f + 0.75*@numofstock_to_mortgage.to_f*@check_stock.currentprice.to_f
                   @stockused = StockUsed.create(:user_id => current_user.id, :stock_id => @stockid,:numofstock => -1*@numofstock_to_mortgage.to_f)
                   @mortgage = Bank.create(:user_id => current_user.id, :stock_id => @stockid,:pricerendered => @check_stock.currentprice, :numofstock => @numofstock_to_mortgage)
                   @user_cash_inhand.save  
                   @extra_cash = 0.75*@numofstock_to_mortgage.to_f*@check_stock.currentprice.to_f
                   @extra_cash = @extra_cash.round(2)
                   flash[:notice] = "Mortgage Successful.$#{@extra_cash} added to your account"
                   @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
              	   redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                else
                   flash[:error] = "Invalid request.You only have #{@check_stock.totalstock} stocks of #{@check_stock.stockname}."
                   @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
              	   redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                end
            elsif params[:identity_bankreturn]
                   logger.info params[:identity_bankreturn]
                   ################## check mortgage again ######################################################
                   @id = params[:identity_bankreturn].split("_")[1]
                   @mortgage = Bank.where("banks.user_id" => current_user.id,"banks.id" => @id).first
                   @user = User.find(current_user.id)
                   @stock = Stock.select("currentprice").where('stocks.id' => @mortgage.stock_id).first
                   #### u can just modifify that that record #####
                   @stockused = StockUsed.create(:user_id => current_user.id, :stock_id => @stock.id,:numofstock => @mortgage.numofstock.to_f)
                   @user.cash = @user.cash - @mortgage.numofstock*@stock.currentprice.to_f
                   @deducted = @mortgage.numofstock*@stock.currentprice

                   if @user.save
                      @mortgage.destroy
                      flash[:notice] = "Stocks retrieved from bank.$#{@deducted} from your account"
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                      redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                   else
                      flash[:error] = "Error processing request.Please try again."
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
                      redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                   end
               else
                  flash[:error] = "Did not recieve request.Please try again."
                  @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
                  redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
               end  
	    	else
	    	  redirect_to :action => 'index'
	    	end ##end of user_signed_in
    end##end of bank_mortgage

    def bank_return_stock
        if user_signed_in?
                   logger.info params[:identity_bankreturn]
                   ################## check mortgage again ######################################################
                   @id = params[:identity_bankreturn].split("_")[1]
                   @mortgage = Bank.where("banks.user_id" => current_user.id,"banks.id" => @id).first
                   @user = User.find(current_user.id)
                   @stock = Stock.select("currentprice").where('stocks.id' => @mortgage.stock_id).first
                   #### u can just modifify that that record #####
                   @stockused = StockUsed.create(:user_id => current_user.id, :stock_id => @mortgage.stock_id,:numofstock => @mortgage.numofstock)
                   @user.cash = @user.cash - @mortgage.numofstock.to_f*@stock.currentprice.to_f
                   @deducted = (@mortgage.numofstock.to_f*@stock.currentprice).round(2);

                   if @user.save
                      @mortgage.destroy
                      flash[:notice] = "Stocks retrieved from bank.$#{@deducted} deducted from your account"
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                      redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                   else
                      flash[:error] = "Error processing request.Please try again."
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
                      redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                   end
        else
           flash[:error] = "Did not recieve request.Please try again."
           @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
           redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
        end  
    end

	  def buy_sell_history
        if user_signed_in?
        	@buy_history = Buy.select("stock_id,numofstock,updated_at,price").where('user_id' => current_user.id).last(10).reverse
        	@sell_history = Sell.select("stock_id,numofstock,updated_at,priceexpected").where('user_id' => current_user.id).last(10).reverse
	        @notifications_list = Notification.get_notice(current_user.id,10)
	        @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
          @notifications_paginate = Notification.order('created_at DESC').limit(7).offset(0) 
          @notifications_count = Notification.count/7  
          @market_events_paginate = MarketEvent.order('created_at DESC').limit(7).offset(0)
          @market_events_count = MarketEvent.count/7
          @stocks_list = Stock.all
          @class_history_active = "class=active"
        else
        	redirect_to :action => 'index'
        end
	  end

    def company
    	if user_signed_in?
	      @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
        @stock = Stock.select("*").first
        @market_event_list = MarketEvent.get_events(10)
        @stock_list = Stock.pluck(:stockname)
        @stock_price = Stock.read_current_price(@stock.id)
        @notifications_list = Notification.get_notice(current_user.id,10)
        @class_company_active = "class=active"
        
        @stocks_list = Stock.all
        @notifications_paginate = Notification.order('created_at DESC').limit(7).offset(0) 
        @notifications_count = Notification.count/7       
        @market_events_paginate = MarketEvent.order('created_at DESC').limit(7).offset(0)
        @market_events_count = MarketEvent.count/7
     else
	      redirect_to :action => 'index'
	    end
    end

end  #class def  
