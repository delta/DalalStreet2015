class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	has_many :stocks
	has_many :buys
	has_many :sells
	has_many :notifications
	has_many :stock_useds
	has_many :logs

#######################################CHECK Time conflictssss...... and write Publish functions for notified user....................................#################
#######################################FAILED u r buying and selling to the same person #########################################################################   
    def self.comparator(mode)
         @offset_buy_count = 0
         @offset_sell_count = 0
         @Buy_table  = Buy.uniq.pluck(:stock_id) 
         @Sell_table = Sell.uniq.pluck(:stock_id)
         @all_ids = @Sell_table + @Buy_table	
         ##select unique ids of stock only
         #########################CAUTION the first id is shifted cause it was nil in development mode ##############################################
         @all_ids = @all_ids.uniq
         @all_ids.shift(1)

         logger.info @all_ids


          @all_ids.each do |id| ##start of buy_sell for each loop comparator
            logger.info id 

             @offset_buy_count = 0
             @offset_sell_count = 0

            Buy.connection.clear_query_cache
            Sell.connection.clear_query_cache
            
             @Buy_id = Buy.select('*').where(:stock_id => id).order('price DESC').first
             @Sell_id = Sell.select('*').where(:stock_id => id).order('priceexpected ASC').first
             
             if !@Buy_id.blank? && !@Sell_id.blank?
                logger.info @Buy_id
                logger.info @Sell_id 
                if @Buy_id.price.to_f >= @Sell_id.priceexpected.to_f
                   @buy_stock_check_looper = User.buy_price_stock_num_looper(id,mode)
                else
                 log_data = "USERID: #{@Buy_id.user_id} STOCKID: #{id} LOG: Sell price is greater than Buy price"
                 @log_file = User.custom_logger(log_data) 
                end #@Buy_id.price >= @Sell_id.priceexpected
             else
              log_data = "USERID: nil STOCKID: #{id} LOG: No stock match found for #{id}"
              @log_file = User.custom_logger(log_data)
             end #@Buy_id && @Sell_id
        
          end  ##end of for each loop .............comparator
                  
    end ##end of comparator def
#############################instance variable @@@@@@@@@@@@@@@@@@ ############# can be access anywhere in a class #########################################
    def self.buy_price_stock_num_looper(id,mode)
        Buy.connection.clear_query_cache
        Sell.connection.clear_query_cache

        @Buy_id = Buy.select('*').where(:stock_id => id).order('price DESC').limit(1).offset(@offset_buy_count).first
        @Sell_id = Sell.select('*').where(:stock_id => id).order('priceexpected ASC').limit(1).offset(@offset_sell_count).first
        
       if !@Buy_id.blank? && !@Sell_id.blank?
        @user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
        @sell_user_stock = StockUsed.select("sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => @Sell_id.user_id,'stock_id' => id).group("stock_id").first

         # logger.info @Buy_id.user_id
         # logger.info @Sell_id.user_id
         # logger.info @user_buying.cash
         # logger.info @Buy_id.price*@Buy_id.numofstock.to_f
         # logger.info @sell_user_stock.totalstock.to_f
         # logger.info @Sell_id.numofstock.to_f

        if @Buy_id.price.to_f >= @Sell_id.priceexpected.to_f
         if (@user_buying.cash >= @Buy_id.price*@Buy_id.numofstock.to_f) && (@sell_user_stock.totalstock.to_f >= @Sell_id.numofstock.to_f) && (@Buy_id.user_id != @Sell_id.user_id)
            @stock_looper = User.stock_looper(id,mode)    
         else
           if @user_buying.cash < @Buy_id.price*@Buy_id.numofstock.to_f
               @offset_buy_count = @offset_buy_count + 1
           elsif @sell_user_stock.totalstock.to_f < @Sell_id.numofstock.to_f
               @offset_sell_count = @offset_sell_count + 1
           else
               @check_next = User.check_next_buy_sell(id,mode)
           end
           @buy_stock_check_looper = User.buy_price_stock_num_looper(id,mode)
         end  
        else
           log_data = "USERID: #{@Buy_id.user_id} STOCKID: #{id} LOG: Sell price is greater than Buy price"
           @log_file = User.custom_logger(log_data) 
        end 
      else
        log_data = "USERID: nil STOCKID: #{id} LOG: No stock match found for #{id}"
        @log_file = User.custom_logger(log_data)
      end

    end  ##end of buy_price_stock_num_looper

    def self.stock_looper(id,mode)    

     	if @Buy_id.numofstock.to_f > @Sell_id.numofstock.to_f

    	    #@user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
    	     @user_buying = User.find(@Buy_id.user_id)
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Sell_id.numofstock.to_f
           logger.info @Buy_id.user_id
           @user_buying.save
          #@user_selling = User.select('cash').where(:id => @Sell_id.user_id).first
           @user_selling = User.find(@Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Sell_id.numofstock.to_f
           @user_selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Sell_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Sell_id.numofstock)
           
           @stockname = Stock.select('stockname,stocksinmarket,stocksinexchange,currentprice').where('id'=>id).first
           User.currentprice_cal(id)

           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Sell_id.numofstock} stocks of #{@stockname.stockname} at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Sell_id.numofstock} stocks of #{@stockname.stockname} at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           WebsocketRails[:buy_sell].trigger(:buy_sell_channel, "true")

           # if mode == "buy"
           # 	 flash[:notice] = "You bought #{@Sell_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share"
           # else
           # 	 flash[:notice] = "You sold #{@Sell_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share"
           # end	 

           @Buy_id.numofstock = @Buy_id.numofstock.to_f - @Sell_id.numofstock.to_f
           @Buy_id.save
           @Sell_id.destroy
          
           if @offset_sell_count != 0 
            @offset_sell_count = @offset_sell_count - 1
           end
           @next_compatible_stock_bid_ask = User.next_compatible_stock_bid_ask(id,mode)
           
        elsif @Buy_id.numofstock.to_f < @Sell_id.numofstock.to_f

           #@user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
           @user_buying = User.find(@Buy_id.user_id)
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Buy_id.numofstock.to_f
           logger.info @Buy_id.user_id
           @user_buying.save
           #@user_selling = User.select('cash').where(:id => @Sell_id.user_id).first
           @user_selling = User.find(@Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Buy_id.numofstock.to_f
           @user_selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Buy_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Buy_id.numofstock)
           
           @stockname = Stock.select('stockname,stocksinmarket,stocksinexchange,currentprice').where('id'=>id).first
           User.currentprice_cal(id)

           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Buy_id.numofstock} stocks of #{@stockname.stockname} at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Buy_id.numofstock} stocks of #{@stockname.stockname} at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           WebsocketRails[:buy_sell].trigger(:buy_sell_channel, "true")

           # if mode == "buy"
           # 	 flash[:notice] = "You bought #{@Buy_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share"
           # else
           # 	 flash[:notice] = "You sold #{@Buy_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share"
           # end	 

           @Sell_id.numofstock = @Sell_id.numofstock.to_f - @Buy_id.numofstock.to_f
           @Sell_id.save
           @Buy_id.destroy

           # if @offset_buy_count != 0 
           #  @offset_buy_count = @offset_buy_count - 1
           # end
           @offset_buy_count = 0
           @next_compatible_stock_bid_ask = User.next_compatible_stock_bid_ask(id,mode)
           
        else
           @user_buying = User.find(@Buy_id.user_id)
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Buy_id.numofstock.to_f
           @user_buying.save
           @user_selling = User.find(@Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Sell_id.numofstock.to_f
           @user_selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Buy_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Sell_id.numofstock)
 
           @stockname = Stock.select('stockname,stocksinmarket,stocksinexchange,currentprice').where('id'=>id).first
           User.currentprice_cal(id)

           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Buy_id.numofstock} stocks of #{@stockname.stockname} at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Sell_id.numofstock} stocks of #{@stockname.stockname} at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
             
           WebsocketRails[:buy_sell].trigger(:buy_sell_channel, "true")
           # if mode == "buy"
           # 	 flash[:notice] = "You bought #{@Buy_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share"
           # else
           # 	 flash[:notice] = "You sold #{@Sell_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share"
           # end	 
           @Buy_id.destroy
           @Sell_id.destroy
           
           if @offset_buy_count != 0 
            @offset_buy_count = @offset_buy_count - 1
           end
           if @offset_sell_count != 0 
            @offset_sell_count = @offset_sell_count - 1
           end
           @next_compatible_stock_bid_ask = User.next_compatible_stock_bid_ask(id,mode)
        end
    end #stock_looper

   def self.next_compatible_stock_bid_ask(id,mode)
        Buy.connection.clear_query_cache
        Sell.connection.clear_query_cache
       	
        @Buy_id = Buy.where(:stock_id => id).order('price DESC').first
        @Sell_id = Sell.where(:stock_id => id).order('priceexpected ASC').first
             if !@Buy_id.blank? && !@Sell_id.blank?
                if @Buy_id.price.to_f >= @Sell_id.priceexpected.to_f
                    @user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
	    	            @sell_user_stock = StockUsed.select("sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => @Sell_id.user_id,'stock_id' => id).group("stock_id").first
                    if @user_buying.cash >= @Buy_id.price*@Buy_id.numofstock.to_f && @sell_user_stock.totalstock.to_f >= @Sell_id.numofstock.to_f && @Buy_id.user_id != @Sell_id.user_id
                       @stock_looper = User.stock_looper(id,mode)  	 
                    else
                       log_data = "USERID: #{@Buy_id.user_id} STOCKID: #{id} LOG: Buyer cash insufficient or Seller don't have enough stocks"
                       @log_file = User.custom_logger(log_data)
                       if @user_buying.cash < @Buy_id.price*@Buy_id.numofstock.to_f
                           @offset_buy_count = @offset_buy_count + 1
                       elsif @sell_user_stock.totalstock.to_f < @Sell_id.numofstock.to_f
                           @offset_sell_count = @offset_sell_count + 1
                       else
                           @check_next = User.check_next_buy_sell(id,mode)
                       end
                       @buy_stock_check_looper = User.buy_price_stock_num_looper(id,mode)
                    end	
                else
                  log_data = "USERID: #{@Buy_id.user_id} STOCKID: #{id} LOG: Sell price is greater than Buy price"
                  @log_file = User.custom_logger(log_data)
                end #@Buy_id.price >= @Sell_id.priceexpected
             else
                 log_data = "USERID: nil STOCKID: #{id} LOG: No matching stock found"
                 @log_file = User.custom_logger(log_data)
                 #@log = Log.create(:user_id => @Buy_id.user_id, :stock_id => id , :log => "Buyer cash insufficient or Seller don't have enough stocks")   
             end #@Buy_id && @Sell_id
   end ###next_compatible_stock_bid_ask def

   def self.custom_logger(log)
     fname = Rails.root.join('log','buy_sell_log.log')
     somefile = File.open(fname, "a")
     time = Time.now
     somefile.puts "time::"+time.to_s+"  "+log+ "\n"
     somefile.close
   end
   
   def self.currentprice_cal(id)
      @stockname = Stock.select('*').where('id'=>id).first
      totalstock = @stockname.stocksinmarket+@stockname.stocksinexchange
      new_price = (@Buy_id.price.to_f*@Buy_id.numofstock.to_f + (totalstock.to_f-@Buy_id.numofstock.to_f)*@stockname.currentprice.to_f)/totalstock.to_f
      
      if new_price < @stockname.currentprice
         @stockname.updown = 0
      else
         @stockname.updown = 1
      end

      @stockname.currentprice = new_price
      @stockname.save
      @update_currentprice_files = Stock.update_current_price(id,@stockname.currentprice)
   end

   def self.check_next_buy_sell(id,mode)
    # count_sell = Sell.where(:stock_id => id).order('priceexpected ASC').count
     @Buy_id = Buy.select('*').where(:stock_id => id).order('price DESC').limit(1).offset(@offset_buy_count+1).first
     @Sell_id = Sell.select('*').where(:stock_id => id).order('priceexpected ASC').limit(1).offset(@offset_sell_count+1).first
    
     if !@Buy_id.blank? && !@Sell_id.blank?
         @offset_buy_count = @offset_buy_count + 1
     elsif @Buy_id.blank? && !@Sell_id.blank?
         @offset_buy_count = 0
         @offset_sell_count = @offset_sell_count + 1
     elsif !@Buy_id.blank? && @Sell_id.blank?
         @offset_sell_count = 0
         @offset_buy_count = @offset_buy_count + 1
     else
         @offset_buy_count = @offset_buy_count + 1
     end
   end ##end of check_next_buy

end
