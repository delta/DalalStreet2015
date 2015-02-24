class AdminController < ApplicationController
    layout "../admin/layout/layout.html.erb"
    http_basic_authenticate_with name: "", password: ""
    def index
        if user_signed_in?
        
          if params[:q]
            @send_all = Message.create(:message => params[:q])
            WebsocketRails[:layout].trigger(:layout_channel, params[:q])
          end  

          # if params[:update]
          #   WebsocketRails[:stock].trigger(:stock_channel, "true");
          # end
        
        end
    end

	def user_details
        	if !user_signed_in?
            	render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
        	else
		          @user_all = User.all.map{|u| [ u.id, u.id ] }
		          @users = User.new
			         if params[:id]
				        @user=User.find(params[:id])
			         end
		      end
	end

	def stockmanipulator
		if !user_signed_in?
            	render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
  	else
      @stock= Stock.new
      @stocks_list = Stock.all
		if params[:order]
		    @stocks_list = Stock.order(params[:order] + " " + sort_direction)
		end

	       if params[:stock]
	           @stock=Stock.new(id:params[:stock][:stock_id],stockname:params[:stock][:stockname],currentprice:params[:stock][:currentprice], stocksinexchange:params[:stock][:stocksinexchange],daylow:params[:stock][:daylow],dayhigh:params[:stock][:dayhigh],alltimelow:params[:stock][:alltimelow],alltimehigh:params[:stock][:alltimehigh],stocksinmarket:params[:stock][:stocksinmarket])
              if @stock.save
                  flash[:queryStatus] = "Saved Successfully"
                  redirect_to action:'stockmanipulator'
              end
  	    end

        if params[:update_id]
    			 @updatestock=Stock.find(params[:update_id])
	      end

 		    if params[:up_id]
     			@updatestock=Stock.find(params[:up_id])
    			if @updatestock.update(stock_params)
    				@updatestock=Stock.delete
    				redirect_to action:'stockmanipulator'

			    end
		    end

		    if params[:delete_id]
     			@deletestock=Stock.find(params[:delete_id]).delete
		    end

    end

  end


    def market_events
        if !user_signed_in?
            render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
        else

            @market_event=MarketEvent.new
            # for deleting market records
            if params[:stk]
                @del_eve=MarketEvent.find_by_stock_id(params[:stk])
                @del_eve.destroy
                redirect_to action:'market_events'
            end

            if params[:market_event]
                 @check=Stock.where("id = ?", params[:market_event][:stock_id]).exists?
                if @check

                    if params[:token]=="1"
                        @market_event=MarketEvent.new(stock_id:params[:market_event][:stock_id],eventname:params[:market_event][:eventname],event_type:params[:market_event][:event_type],event:params[:market_event][:event],event_turn:params[:market_event][:event_turn],event_done:params[:market_event][:event_done])
                    else
                        @market_event=MarketEvent.find_by_stock_id(params[:market_event][:stock_id])
                        @market_event.eventname=params[:market_event][:eventname]
                        @market_event.event_turn=params[:market_event][:event_turn]
                        @market_event.event_type=params[:market_event][:event_type]
                        @market_event.event_done=params[:market_event][:event_done]
                        @market_event.event=params[:market_event][:event]

                    end
                    @destroyed =false
                else
                    @market_event.destroy
                    @destroyed =true
                    flash[:Error]="The requested operation has failed,Possibly,the Stock ID doesn't exits yet"
                    redirect_to action:'market_events'
                end

                if not @destroyed
                    if @market_event.save
                        flash[:queryStatus] = "Saved Successfully"
                        redirect_to action:'market_events'
                    end
                end
            end

            if !MarketEvent.all.empty?
                @stock= Stock.all
                @no_of_row=6

                if params[:order]
                    if params[:search]
                            @allEvent = MarketEvent.select("*").where("stock_id=#{params[:search]}").order(params[:order]+ " " + sort_direction).paginate(:page => params[:page], :per_page => @no_of_row)
                    else
                            @allEvent = MarketEvent.order(params[:order]+ " " + sort_direction).paginate(:page => params[:page], :per_page => @no_of_row)
                    end
                else
                    if(params[:search])
                        @allEvent = MarketEvent.select("*").where("stock_id=#{params[:search]}").paginate(:page => params[:page], :per_page => @no_of_row)
                    else
                        @allEvent = MarketEvent.paginate(:page => params[:page], :per_page => @no_of_row)
                    end
                end

            else
                @allEvent="Event Empty. Please add new Events"
            end


        end

    end

    def company_events
      if !user_signed_in?
        render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"

      else
        @stocks_list = Stock.new
        @stocks_all=Stock.all


          if params[:token]

            Stock.find_each do |s|

                if params["#{s.id}"].present?
                  s.stocksinexchange= params["#{s.id}"]

                      if s.save
                         flash[:qS]="Stocks Updated"
                         WebsocketRails[:stock].trigger(:stock_channel, "true");
                       else
                         flash[:Er]="Error occurred in updating Stocks."
                      end

                end
              end

            end


        end

      end

    def bank_rates
        if !user_signed_in?
                render :text => "<h2>User not authenticated.Please <a href='/index/index' >login</a></h2>"
        else
          @bank= Bank.new
          @banks_list = Bank.all

            if params[:update_id]
                     @updatebankrates=Bank.find(params[:update_id])
              end

                if params[:up_id]
                    @updatebankrates=Bank.find(params[:up_id])
                    if @updatebankrates.update(stock_params)
                        @updatebankrates=Bank.delete
                        redirect_to action:'bank_rates'

                    end
                end

                if params[:delete_id]
                    @deletestock=Bank.find(params[:delete_id]).delete
                end
        end
     end



	private
	def stock_params
 		params.require(:updatestock).permit(:stock_id, :stockname, :currentprice, :stocksinexchange, :daylow, :dayhigh, :alltimelow, :alltimehigh , :stocksinmarket)
	end
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
        end

end
