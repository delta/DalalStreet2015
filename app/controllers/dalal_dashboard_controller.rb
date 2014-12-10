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
		## the chart and pie charts fix em .........works only on reload ...... #####################
		if request.get?
		   if !user_signed_in?
	         redirect_to :action => 'index'
	       else
	       	  @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	          @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => current_user.id).group("stock_id")
	          
	          #@total_stock_price = Stock.find(:all, :joins => [:stock_useds], :select => "stocks.*,sum(stock_useds.numofstock) as totalstock", :conditions => 'stock_useds.user_id' => current_user.id, :group => "stock_id")
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

########################IMPORTANT :::::: Dont forget to block url to http://0.0.0.0:3000/dalal_dashboard/298486374/buy_sell_stock :::::####################################
    def buy_sell_stock
      if request.get? 	
    	if user_signed_in?
    		logger.info "Inside"
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

protected
    def comparator 
         
         @Buy_table  = Buy.uniq.pluck(:stock_id) 
         @Sell_table = Sell.uniq.pluck(:stock_id)
         @all_ids = @Sell_table + @Buy_table	
         ##select unique ids of stcok only
         @all_ids = @all_ids.uniq
         logger.info @all_ids


          @all_ids.each do |id| ##start of buy_sell for each loop comparator
            logger.info id  
            
             @Buy_id = Buy.where(:stock_id => id).order('price DESC').first
             @Sell_id = Sell.where(:stock_id => id).order('priceexpected ASC').first
             
             if @Buy_id && @Sell_id
                logger.info @Buy_id
                logger.info @Sell_id 
                if @Buy_id.price >= @Sell_id.priceexpected
                	##check for cash in buy user ## check for stock in sell user
                    @user_buying = User.select('cash').where(:id => @Buy_id.user_id)
	    	        @sell_user_stock = StockUsed.select("sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => @Sell_id.user_id,'stocks.id' => id).group("stock_id")
                    if @user_buying.cash >= @Buy_id.price*@Buy_id.numofstock && @sell_user_stock.totalstock >= @Sell_id.numofstock
                     stock_looper @Buy_id @Sell_id  	 
                    else
                     @log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id, :log => "Buyer cash insufficient or Seller don't have enough stocks")	 
                    end	
                else
                 @log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id, :log => "Sell price is greater than Buy price")	 
                end #@Buy_id.price >= @Sell_id.priceexpected
             else   
              @log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id, :log => "No stock match found")	 
             end #@Buy_id && @Sell_id
        
          end  ##end of for each loop .............comparator
                  
    end ##end of comparator def


    def stock_looper Buy_id Sell_id    ####recursive function
    	if @Buy_id.numofstock > @Sell_id.numofstock

    	   @user_buying = User.select('cash').where(:id => @Buy_id.user_id) 
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Sell_id.numofstock
           @user_buying.save
           @user_selling = User.select('cash').where(:id => @Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Sell_id.numofstock
           @user.selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Sell_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Sell_id.numofstock)
           
           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Sell_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Sell_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           @Buy_id.numofstock = @Buy_id.numofstock - @Sell_id.numofstock
           @Buy_id.save
           @Sell_id.destroy

           next_compatible_stock_bid_ask

        elsif @Buy_id.numofstock < @Sell_id.numofstock

           @user_buying = User.select('cash').where(:id => @Buy_id.user_id) 
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Buy_id.numofstock
           @user_buying.save
           @user_selling = User.select('cash').where(:id => @Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Buy_id.numofstock
           @user.selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Buy_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Buy_id.numofstock)
           
           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Buy_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Buy_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           @Sell_id.numofstock = @Sell_id.numofstock - @Buy_id.numofstock
           @Sell_id.save
           @Buy_id.destroy

           next_compatible_stock_bid_ask

        else
           @user_buying = User.select('cash').where(:id => @Buy_id.user_id) 
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Buy_id.numofstock
           @user_buying.save
           @user_selling = User.select('cash').where(:id => @Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Sell_id.numofstock
           @user.selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Buy_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Sell_id.numofstock)
 
           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Buy_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Sell_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           @Buy_id.destroy
           @Sell_id.destroy
        end
    end #stock_looper

    def next_compatible_stock_bid_ask

    	@Buy_id = Buy.where(:stock_id => id).order('price DESC').first
        @Sell_id = Sell.where(:stock_id => id).order('priceexpected ASC').first
             
             if @Buy_id && @Sell_id
                logger.info @Buy_id
                logger.info @Sell_id 
                if @Buy_id.price >= @Sell_id.priceexpected
                    @user_buying = User.select('cash').where(:id => @Buy_id.user_id)
	    	        @sell_user_stock = StockUsed.select("sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => @Sell_id.user_id,'stocks.id' => id).group("stock_id")
                    if @user_buying.cash >= @Buy_id.price*@Buy_id.numofstock && @sell_user_stock.totalstock >= @Sell_id.numofstock
                     stock_looper @Buy_id @Sell_id  	 
                    else
                     @log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id, :log => "Buyer cash insufficient or Seller don't have enough stocks")	 
                    end	
                else
                 @log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id, :log => "Sell price is greater than Buy price")	 
                end #@Buy_id.price >= @Sell_id.priceexpected
             else   
              @log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id, :log => "No stock match found")	 
             end #@Buy_id && @Sell_id
        
    end ###next_compatible_stock_bid_ask def

end  #class def  
