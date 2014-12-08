class SocketController < WebsocketRails::BaseController
before_filter :authenticate_user!
require "json"

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

    def buy_and_sell_handler
    	if user_signed_in?
           
    	else
    			
    	end
    end    

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
                ##WebsocketRails.users[current_user.id].send_message('new_notification', {:message => 'you\'ve got an upvote '})
                    broadcast_message :stock_ajax_handler, :sent_data => { :current_user => current_user.id,:stock_update => @stockall}  
               else
                    broadcast_message :stock_ajax_handler, :sent_data => { :current_user => current_user.id,:stock_update => @stockall}
               end
                ## end update block send response to client
           
           else
              send_message :stock_ajax_handler, flash[:error]
              redirect_to :action => 'index'
           end     ##if not user signed in block
    end #stock_ajax_handle def block


    def update_stock_market
        if user_signed_in?
           # logger.info params[:connected]
           # if params[:connected] 
              @stockall = Stock.all
              broadcast_message :update_stock_market, :sent_data => {:notice => flash[:notice],:stock_update => @stockall}
           # end
        else
           flash[:error] = "You have encountered an unexpected error.Please login and Try again."
           #send_message :update_stock_market, :sent_data => {:error => flash[:error],:stock_update => @stockall}
           redirect_to :action => 'index'
        end  
      
    end

end ## end of socket controller
 