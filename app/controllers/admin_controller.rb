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
                #@market_event=MarketEvent.new_event(params[:market_event][:id],params[:market_event][:eventname],params[:market_event][:event_type],params[:market_event][:event],params[:market_event][:event_turn],params[:market_event][:event_done])
                if @market_event.save
                    flash[:queryStatus] = "Saved Successfully"
                end
            end
            # showing all events
            if !MarketEvent.all.empty?
                @allEvent=MarketEvent.all
                
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
         if !user_signed_in?
            render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
            
         end
    end

end
