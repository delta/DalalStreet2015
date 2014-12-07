class SocketController < WebsocketRails::BaseController
before_filter :authenticate_user!
require "json"

	def notification_update 
	    if user_signed_in?	
	        @receive = params[:receive] 
	        @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
	        ## new_message = {:message => 'this is a message'}
            send_message :notification_update, @notifications_list.to_json
        else
	       @not_signed_in = "You are not signed in.Please sign in first."
	        new_message = {:message => @not_signed_in}
            send_message :notification_update, new_message.to_json
        end
    end  ##end of #notification updates

    def market_fluctuations
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
               if @success == 1
                    @stockall = Stock.all
                    send_message :stock_ajax_handler, sent_data => { :notice => flash[:notice],:stock_update => @stockall}  
               else
                    send_message :stock_ajax_handler, sent_data => { :notice => flash[:error] }
               end
                ## end update block send response to client
           
           else
              send_message :stock_ajax_handler, flash[:error]
              redirect_to :action => 'index'
           end     ##if not user signed in block
    end #stock_ajax_handle def block


end
