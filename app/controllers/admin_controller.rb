class AdminController < ApplicationController
	layout "../admin/layout/layout.html.erb"

	def index
        if !user_signed_in?
            render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
              
        end
            
	end
    
    def market_events
        if !user_signed_in?
            render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
        else
            @market_event=MarketEvent.new
            # creating new event
            if params[:market_event] 
                @market_event=MarketEvent.new(stock_id:params[:market_event][:stock_id],eventname:params[:market_event][:eventname],event_type:params[:market_event][:event_type],event:params[:market_event][:event],event_turn:params[:market_event][:event_turn],event_done:params[:market_event][:event_done])
                if @market_event.save
                    flash[:queryStatus] = "Saved Successfully"
                    redirect_to action:'market_events'
                end
            end
            # showing all events
            if !MarketEvent.all.empty?
                @stock= Stock.paginate(:page => params[:page], :per_page => 5)
                @allEvent = MarketEvent.paginate(:page => params[:page], :per_page => 5)
                
            else
                @allEvent="Event Empty. Please add new Events"    
            end    
        end
        
    end
    
    def company_events
        if !user_signed_in?
            render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
            
        end
        
        
    end
    
    def bank_rates
         if user_signed_in?
            Stock.connection.clear_query_cache
                @stocks_list = Stock.all
                @notifications_list = Notification.select("notification,updated_at").where('user_id' => current_user.id).last(10).reverse
              @price_of_tot_stock = Stock.get_total_stock_price(current_user.id)
           else
              redirect_to :action => 'index'
           end    
    end

end
