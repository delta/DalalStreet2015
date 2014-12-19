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

               if @stock_bought.stocksinexchange > @numofstock and @numofstock > 0
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
                  flash[:error] = "Invalid trade parameters.Please check and try again."
                  @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3)
               end      

            else
               flash[:error] = "Did not receive request #{@numofstock} stocks of #{@stock_bought.stockname}.TRADE FAILED"
               @notification = Notification.create(:user_id =>current_user.id, :notification => flash[:error], :seen => 1, :notice_type => 3) 
            end ##main if block 1

                ## update block send response to client
                @stockall = Stock.all
               if @success == 1
                    WebsocketRails[:stocks].trigger(:channel_update_stock_user, "true")
                    broadcast_message :stock_ajax_handler, :sent_stock_data => { :current_user => current_user.id,:stock_update => @stockall}  
               else
                    broadcast_message :stock_ajax_handler, :ent_stock_data => { :current_user => current_user.id,:stock_update => @stockall}
               end
                ## end update block send response to client
           
           else
              send_message :stock_ajax_handler, flash[:error]
              redirect_to :action => 'index'
           end     ##if not user signed in block
    end #stock_ajax_handle def block


    def update_stock_user
        if user_signed_in?
              Stock.connection.clear_query_cache
              @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => current_user.id).group("stock_id")
              @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
              send_message :update_stock_user, :sent_data => {:notice => @notifications_list,:stock_update => @stocks}
        else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end  
    end

    def update_stock_all
       if user_signed_in?
              @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
              @stocks = Stock.all
              send_message :update_stock_all, :sent_data => {:notice => @notifications_list,:stock_update => @stocks}
        else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end
    end

    def self.call_update_stock_user
       WebsocketRails[:stocks].trigger(:channel_update_stock_user, "true")
    end

    def company_handler
       if user_signed_in?
           company_name = data[:name]
           stock = Stock.select("*").where("stockname" => company_name).first
           stock_price = Stock.read_current_price(stock.id)
           @get_market_event = MarketEvent.select("eventname,updated_at").where("stock_id" => stock.id).last(10).reverse
           send_message :company_handler, :sent_data => {:market_list => @get_market_event,:price_list => stock_price,:stock_details => stock}
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
      
      update_partial_input('dalal_dashboard/buy_sell_partial', :@stock, @stock);
      update_partial_input('dalal_dashboard/buy_sell_partial', :@no_stock_found , @no_stock_found);
      data = {};
      data = load_data_with_partials(data);
      send_message :buy_sell_partial_render, data
      else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           redirect_to :action => 'index'
        end
      #{:controller=>"dalal_dashboard",:id =>"#{current_user.id}",:action =>"buy_sell_stock",:stockname =>"#{stock.stockname}"},

     end 

     def bank_mortgage_partial_render
      if user_signed_in?
        id = data[:id]
        @stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id,'stock_useds.stock_id' => id).group("stock_id").first

        update_partial_input('dalal_dashboard/bank_mortgage_partial', :@stock, @stock);

        data = {};
        data = load_data_with_partials(data);
        send_message :bank_mortgage_partial_render, data

        else
          flash[:error] = "You have encountered an unexpected error.Please login and Try again."
          redirect_to :action => 'index'
        end
     end 
end ## end of socket controller
 