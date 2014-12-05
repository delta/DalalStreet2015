class DalalDashboardController < WebsocketRails::ApplicationController
before_filter :authenticate_user! #devise filters#
protect_from_forgery with: :null_session

require "json"

layout "../dalal_dashboard/layout/layout.html.erb"

	def index
		if user_signed_in?
         #caution ::::   change to devise parameters later #####
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
	        	@notifications_list = Notification.last(10).reverse
	       else
	          redirect_to :action => 'index'
	       end	   
    end #stock def

    def stock_ajax_handler
       
	       if user_signed_in?
              @success = 0
       	      @stockidbought = params[:identity].split("_")[1]
       	      @numofstock = params[params[:identity]]
              @numofstock = @numofstock.to_f ##convert to integer

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

			  respond_to do |format| ## respond block to check ajax request and render json data
			    if @success == 1
			       format.html {redirect_to :controller=>'dalal_dashboard', :id => current_user.id, :action=>'stock', notice: "#{@numofstock} stocks of #{@stock_bought.stockname} traded successfully" }
			       format.json {render json: flash[:notice].to_json }
			    else
			       format.html {redirect_to :controller=>'dalal_dashboard', :id => current_user.id, :action=>'stock', error: "#{@numofstock} stocks of #{@stock_bought.stockname} Traded Failed" }
			       format.json {render json: flash[:error].to_json }
			    end	
	          end  #respond block 
	       
	       else
	          redirect_to :action => 'index'
	       end	   
    end #stock_ajax_handle def block


    def buy_sell
    
	    if user_signed_in?

	    	   @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => current_user.id).group("stock_id")
	           @notifications_list = Notification.last(10).reverse

	          ##create methos to get the total stock price of the user#############
              #######################

	    else
	       redirect_to :action => 'index'
	    end

    end ####end of buy def


    def buy_sell_ajax_handler
    
	    if user_signed_in?
	    		

	    else
	       redirect_to :action => 'index'
	    end

    end ####end of sell def

end  #class def  
