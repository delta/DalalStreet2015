class SocketController < WebsocketRails::BaseController
include SocketHelper
before_filter :authenticate_user!
require "json"
# include RestfulWebsocketsHelper

    def initialize_session
    # perform application setup here
    controller_store[:message_count] = 0
    end

	def notification_update 
	    if user_signed_in?
	        @receive = params[:receive] 
	        @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
          send_message :notification_update, :notice => @notifications_list
        else
	        @not_signed_in = "You are not signed in.Please sign in first."
          send_message :notification_update, :notice =>  @not_signed_in
        end
    end  ##end of #notification updates   

   def stock_ajax_handler
           if user_signed_in?
              @success = 0
              @numofstock = data[:value]
              @stockidbought = data[:identity]
              @numofstock = @numofstock.to_f ##convert to integer
       
              logger.info data[:value]
       
            if @stockidbought && @numofstock ##main if block 1 enters only if ajax variables are recieved
               @stock_bought = Stock.find(@stockidbought)

               if @stock_bought.stocksinexchange > @numofstock and @numofstock > 0 and @numofstock <= 10
                  @total_price_of_bought_stock = @numofstock*@stock_bought.currentprice
                  @user_cash_inhand = User.find(current_user.id)
                    if @user_cash_inhand.cash - @total_price_of_bought_stock > 0
                       @user_cash_inhand.cash = @user_cash_inhand.cash-@total_price_of_bought_stock
                       @stock_bought.stocksinexchange = @stock_bought.stocksinexchange - @numofstock
                       @stock_bought.stocksinmarket = @stock_bought.stocksinmarket + @numofstock
                       @stock_bought.save
                       @user_cash_inhand.save
                       @stockused = StockUsed.create(:user_id => current_user.id, :stock_id => @stockidbought,:numofstock => @numofstock)
                       flash[:notice] = "#{@numofstock} stocks of #{@stock_bought.stockname} traded successfully"
                       @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                       @success = 1
                    else
                       flash[:error] = "Not Enough Cash to trade #{@numofstock} stocks of #{@stock_bought.stockname}.You can get cash by mortgaging stocks at the Bank."
                       @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                    end
               else
                  if @numofstock > 10
                    flash[:error] = "You cannot trade more than 10 stocks at a time.Trade failed."
                    @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
                  else
                    flash[:error] = "Invalid trade parameters.Please check and try again."
                    @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
                  end
               end      
            else
               flash[:error] = "Did not receive request #{@numofstock} stocks of #{@stock_bought.stockname}.TRADE FAILED"
               @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3) 
            end ##main if block 1

               @stockall = Stock.all
               if @success == 1
                  stock_ajax_handler_helper(@stockall)
               else
                  stock_ajax_handler_helper(@stockall)
               end ## end update block send response to client
               
           else
              send_message :stock_ajax_handler, flash[:error]
              redirect_to :action => 'index'
           end     ##if not user signed in block
    end #stock_ajax_handle def block


    def update_stock_user
        if user_signed_in?
              Stock.connection.clear_query_cache
              @stocks_list = Stock.all
              @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => current_user.id).group("stock_id")
              @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
              #send_message :update_stock_user, :sent_data => {:notice => @notifications_list,:stock_update => @stocks}
              @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
              @user_cash_inhand = User.find(current_user.id)
              @user_current_cash = @user_cash_inhand.cash.round(2)
              @market_events_paginate = MarketEvent.page(1).per(10)
              @market_events_total = MarketEvent.count
             
              update_partial_input('dalal_dashboard/partials/show_partial', :@stocks, @stocks)
              update_partial_input('dalal_dashboard/partials/notification_partial', :@notifications_list , @notifications_list)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@price_of_tot_stock, @price_of_tot_stock )
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@stocks_list, @stocks_list )
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@market_events_paginate , @market_events_paginate)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@user_current_cash,@user_current_cash)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@market_events_total,@market_events_total)
             
              data = {}
              data = load_data_with_partials(data)
              send_message :update_stock_user, data
        else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end  
    end

    def update_stock_all
       if user_signed_in?
              Stock.connection.clear_query_cache
              @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
              @stocks_list = Stock.all
              @market_events_paginate = MarketEvent.page(1).per(10)
              @market_events_total = MarketEvent.count

              #send_message :update_stock_all, :sent_data => {:notice => @notifications_list,:stock_update => @stocks}
              @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
              @user_cash_inhand = User.find(current_user.id)
              @user_current_cash = @user_cash_inhand.cash.round(2)
              
              update_partial_input('dalal_dashboard/partials/main_buy_sell_partial', :@stocks_list, @stocks_list)
              update_partial_input('dalal_dashboard/partials/notification_partial', :@notifications_list , @notifications_list)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@price_of_tot_stock ,  @price_of_tot_stock)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@stocks_list, @stocks_list )
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@market_events_paginate , @market_events_paginate)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@user_current_cash,@user_current_cash)
              update_partial_input('dalal_dashboard/partials/panel_dashboard_partial', :@market_events_total,@market_events_total)
             
              data = {}
              data = load_data_with_partials(data)
              send_message :update_stock_all, data
        else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end
    end

    def self.call_update_stock_user
       WebsocketRails[:show].trigger(:show_channel, "true")
       WebsocketRails[:buy_sell].trigger(:buy_sell_channel, "true")
       WebsocketRails[:index].trigger(:index_channel, "true");
    end

    def company_handler
       if user_signed_in?
           company_name = data[:name]
           @stock = Stock.select("*").where("stockname" => company_name).first
           @price_list = Stock.read_current_price(@stock.id)
           @market_event_list = MarketEvent.select("eventname,updated_at").where("stock_id" => @stock.id).last(10).reverse

           update_partial_input('dalal_dashboard/partials/company_partial', :@stock , @stock)
           update_partial_input('dalal_dashboard/partials/marketevent_partial', :@market_event_list , @market_event_list)
           update_partial_input('dalal_dashboard/partials/chart_partial', :@price_list , @price_list)
           update_partial_input('dalal_dashboard/partials/chart_partial_2', :@price_list , @price_list)
           update_partial_input('dalal_dashboard/partials/chart_partial_2', :@stocksinmarket , @stock.stocksinmarket)
           
           data = {}
           data = load_data_with_partials(data)
           send_message :company_handler, data
           
           # send_message :company_handler, :sent_data => {:market_list => @get_market_event,:price_list => stock_price,:stock_details => stock}
        else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end
    end

    def buy_sell_partial_render
      if user_signed_in?
       id = data[:id]
       logger.info id
       @stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stock_useds.stock_id' => id).group("stock_id").first
       @no_stock_found = nil
       
       if !@stock
         @stock = Stock.select("*").where('stocks.id' => id).first
         @no_stock_found = "You do not own Stocks belonging to this Company.To buy stocks send a bid request first."
       end   
      
      @buy_history = Buy.get_buy_history(id,3)
      @sell_history = Sell.get_sell_history(id,3)

      # @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
      # @user_cash_inhand = User.find(current_user.id)
      # @user_current_cash = @user_cash_inhand.cash.round(2)

          update_partial_input('dalal_dashboard/partials/buy_sell_partial_socket', :@stock, @stock)
          update_partial_input('dalal_dashboard/partials/buy_sell_partial_socket', :@no_stock_found , @no_stock_found)
          update_partial_input('dalal_dashboard/partials/buy_sell_partial_socket', :@buy_history, @buy_history)
          update_partial_input('dalal_dashboard/partials/buy_sell_partial_socket', :@sell_history, @sell_history)
      
      data = {}
      data = load_data_with_partials(data)
      send_message :buy_sell_partial_render, data
      else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end
     end 

     def bank_mortgage_partial_render
      if user_signed_in?
        id = data[:id]
        @stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stock_useds.stock_id' => id).group("stock_id").first
        @mortgage = Stock.joins(:banks).select("*,banks.numofstock*stocks.currentprice as netcash").where("banks.user_id" => current_user.id,"banks.stock_id" => id)
        @no_mortgage = nil
        
        if @mortgage.blank?
         @no_mortgage = "You have not mortgaged any stocks of #{@stock.stockname} yet."
        end
          
        update_partial_input('dalal_dashboard/partials/bank_mortgage_partial_socket', :@stock, @stock)
        update_partial_input('dalal_dashboard/partials/bank_mortgage_partial_socket', :@mortgage, @mortgage)
        update_partial_input('dalal_dashboard/partials/bank_mortgage_partial_socket', :@no_mortgage, @no_mortgage)
        
        data = {}
        data = load_data_with_partials(data)
        send_message :bank_mortgage_partial_render, data

        else
          flash[:error] = "You have encountered an unexpected error.Please login and Try again."
          redirect_to :action => 'index'
        end
     end 

     def update_modal_partials
      if user_signed_in?
         page = data[:page]
         @active = page
         
       if data[:type] == "market"
         skip = page.to_f*7
         @market_events_count = MarketEvent.count/7
         MarketEvent.connection.clear_query_cache
         @market_events_paginate = MarketEvent.limit(7).offset(skip)
         update_partial_input('dalal_dashboard/partials/marketevent_modal_partial', :@market_events_paginate, @market_events_paginate)
         update_partial_input('dalal_dashboard/partials/marketevent_modal_partial', :@market_events_count, @market_events_count)
         update_partial_input('dalal_dashboard/partials/marketevent_modal_partial', :@active, @active)
       end

       if data[:type] == "notice"
         skip = page.to_f*7
         @notifications_count = Notification.count/7
         @notifications_paginate = Notification.limit(7).offset(skip)
         update_partial_input('dalal_dashboard/partials/notification_modal_partial', :@notifications_paginate, @notifications_paginate)
         update_partial_input('dalal_dashboard/partials/notification_modal_partial', :@notifications_count, @notifications_count)
         update_partial_input('dalal_dashboard/partials/notification_modal_partial', :@active, @active)
       end      

       data = {}
       data = load_data_with_partials(data)
       send_message :update_modal_partials, data
      else
       flash[:error] = "You have encountered an unexpected error.Please login and Try again."
       redirect_to :action => 'index'
      end
     end 

     def buy_sell_stock_socket
        if user_signed_in?
           @type = data[:type_stock].split("_")[0]

          if @type == 'buy' && !data[:num_of_stock].blank? && !data[:price].blank?
                @stockid = data[:type_stock].split("_")[1]
                @numofstock_buy_for = data[:num_of_stock]
                @bid_price = data[:price]
                @stock = Stock.find(@stockid) 
                @user_cash_inhand = User.find(current_user.id)
             
              if @stock.stocksinmarket.to_f >= @numofstock_buy_for.to_f
                 if @bid_price.to_f <= (0.1*@stock.currentprice.to_f+@stock.currentprice.to_f)
                   if @user_cash_inhand.cash.to_f >= @numofstock_buy_for.to_f*@bid_price.to_f 
                      @buy_bid = Buy.create(:user_id=>current_user.id, :stock_id=>@stockid, :price=>@bid_price, :numofstock=>@numofstock_buy_for)
                      flash[:notice] = "Successful Bid."
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                        ## call comparator ##can be made efficient
                      @comparator = User.comparator("buy")
                      buy_sell_stock_socket_helper
                   else
                      flash[:error] = "Buy request failed.You only have $ #{@user_cash_inhand.cash}."
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                      buy_sell_stock_socket_helper
                   end
                 else
                  @max_bid_price = (0.1*@stock.currentprice.to_f+@stock.currentprice.to_f).round(2)
                  flash[:error] = "You cannot bid for more than 10% of the current price the max buy price for #{@stock.stockname} is #{@max_bid_price}."
                  @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                  buy_sell_stock_socket_helper   
                 end  
              else
                 flash[:error] = "Buy request failed.There are only #{@stock.stocksinmarket} stocks in the market."
                 @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                 buy_sell_stock_socket_helper
              end

         elsif @type == 'sell' && !data[:num_of_stock].blank? && !data[:price].blank?
                @stockid = data[:type_stock].split("_")[1]
                @numofstock_sell_for = data[:num_of_stock]
                @ask_price = data[:price]
                @user_stock_inhand = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stocks.id' => @stockid ).group("stock_id")
                 
                if @user_stock_inhand[0].totalstock.to_f >= @numofstock_sell_for.to_f
                  @sell_ask  = Sell.create(:user_id=>current_user.id, :stock_id=>@stockid, :priceexpected=>@ask_price, :numofstock=>@numofstock_sell_for)
                  flash[:notice] = "Sell request made."
                  @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:notice], :seen => 1, :notice_type => 1)
                    ## call comparator ##can be made efficient
                  @comparator = User.comparator("sell")
                  buy_sell_stock_socket_helper
                else
                  flash[:error] = "Sell request failed.You only have #{@user_stock_inhand[0].totalstock} stocks of #{@user_stock_inhand[0].stockname}."
                  @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                  buy_sell_stock_socket_helper
                end
         else
            flash[:error] = "Did Not receive request.Please try again."
            @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
            buy_sell_stock_socket_helper
         end
        else
          flash[:error] = "You have encountered an unexpected error.Please login and Try again."
          redirect_to :action => 'index'
        end
     end

     def bank_mortgage_socket
      if user_signed_in?
           @type = data[:type_stock].split("_")[0]
 
          if @type == 'bank' && !data[:num_of_stock].blank?
                @stockid = data[:type_stock].split("_")[1]
                @numofstock_to_mortgage = data[:num_of_stock]
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
                   bank_mortgage_socket_helper
                   # redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                else
                   flash[:error] = "Invalid request.You only have #{@check_stock.totalstock} stocks of #{@check_stock.stockname}."
                   @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 2)
                   bank_mortgage_socket_helper
                   # redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                end
            elsif @type == 'bankreturn'
                   logger.info data[:type_stock]
                   ################## check mortgage again ######################################################
                   @id = data[:type_stock].split("_")[1]
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
                      bank_mortgage_socket_helper
                      # redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                   else
                      flash[:error] = "Error processing request.Please try again."
                      @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
                      bank_mortgage_socket_helper
                      # redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
                   end
        else
           flash[:error] = "Did not recieve request.Please try again."
           @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
           bank_mortgage_socket_helper
           # redirect_to :controller=>'dalal_dashboard', :id=>current_user.id, :action=>'bank_mortgage'
        end  
        else
          flash[:error] = "You have encountered an unexpected error.Please login and Try again."
          redirect_to :action => 'index'
        end ##end of user_signed_in
     end

     def index_updater
              Stock.connection.clear_query_cache
              @stocks_list = Stock.all
              @market_events_paginate = MarketEvent.page(1).per(10)

              update_partial_input('dalal_dashboard/partials/stock_marquee_partial', :@stocks_list, @stocks_list )

              data = {}
              data = load_data_with_partials(data)
              send_message :index_updater, data
     end

end ## end of socket controller
 