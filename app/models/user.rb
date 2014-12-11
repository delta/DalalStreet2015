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
    def self.comparator 
         
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
            
             @Buy_id = Buy.select('*').where(:stock_id => id).order('price DESC').first
             @Sell_id = Sell.select('*').where(:stock_id => id).order('priceexpected ASC').first
             
             if @Buy_id && @Sell_id
                logger.info @Buy_id
                logger.info @Sell_id 
                if @Buy_id.price >= @Sell_id.priceexpected
                	##check for cash in buy user ## check for stock in sell user
                    @user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
	    	        @sell_user_stock = StockUsed.select("sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => @Sell_id.user_id,'stock_id' => id).group("stock_id").first
                    if @user_buying.cash >= @Buy_id.price*@Buy_id.numofstock && @sell_user_stock.totalstock >= @Sell_id.numofstock
                       @stock_looper = User.stock_looper(id)  	 
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


    def self.stock_looper(id)    

    	  @Buy_id = Buy.select('*').where(:stock_id => id).order('price DESC').first
          @Sell_id = Sell.select('*').where(:stock_id => id).order('priceexpected ASC').first

    	if @Buy_id.numofstock > @Sell_id.numofstock

    	   #@user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
    	   @user_buying = User.find(@Buy_id.user_id)
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Sell_id.numofstock
           logger.info @Buy_id.user_id
           @user_buying.save
          #@user_selling = User.select('cash').where(:id => @Sell_id.user_id).first
           @user_selling = User.find(@Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Sell_id.numofstock
           @user_selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Sell_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Sell_id.numofstock)
           
           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Sell_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Sell_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           @Buy_id.numofstock = @Buy_id.numofstock - @Sell_id.numofstock
           @Buy_id.save
           @Sell_id.destroy

           @next_compatible_stock_bid_ask = User.next_compatible_stock_bid_ask(id)

        elsif @Buy_id.numofstock < @Sell_id.numofstock

           #@user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
           @user_buying = User.find(@Buy_id.user_id)
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Buy_id.numofstock
           logger.info @Buy_id.user_id
           @user_buying.save
           #@user_selling = User.select('cash').where(:id => @Sell_id.user_id).first
           @user_selling = User.find(@Sell_id.user_id)
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Buy_id.numofstock
           @user_selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Buy_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Buy_id.numofstock)
           
           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Buy_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Buy_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           @Sell_id.numofstock = @Sell_id.numofstock - @Buy_id.numofstock
           @Sell_id.save
           @Buy_id.destroy

           @next_compatible_stock_bid_ask = User.next_compatible_stock_bid_ask(id)
           
        else
           @user_buying = User.select('cash').where(:id => @Buy_id.user_id).first 
           @user_buying.cash = @user_buying.cash - @Buy_id.price*@Buy_id.numofstock
           @user_buying.save
           @user_selling = User.select('cash').where(:id => @Sell_id.user_id).first
           @user_selling.cash = @user_selling.cash + @Sell_id.priceexpected*@Sell_id.numofstock
           @user_selling.save

           @stockused = StockUsed.create(:user_id => @Buy_id.user_id, :stock_id => @Buy_id.stock_id,:numofstock => @Buy_id.numofstock)
           @stockused = StockUsed.create(:user_id => @Sell_id.user_id, :stock_id => @Sell_id.stock_id,:numofstock => -@Sell_id.numofstock)
 
           @notification = Notification.create(:user_id =>@Buy_id.user_id, :notification => "You bought #{@Buy_id.numofstock} stocks at the rate of $#{@Buy_id.price} per share", :seen => 1, :notice_type => 1)
           @notification = Notification.create(:user_id =>@Sell_id.user_id, :notification => "You sold #{@Sell_id.numofstock} stocks at the rate of $#{@Sell_id.priceexpected} per share", :seen => 1, :notice_type => 1)
           
           @Buy_id.destroy
           @Sell_id.destroy
        end
    end #stock_looper

    def self.next_compatible_stock_bid_ask(id)

    	@Buy_id = Buy.where(:stock_id => id).order('price DESC').first
        @Sell_id = Sell.where(:stock_id => id).order('priceexpected ASC').first
             
             if @Buy_id && @Sell_id
                logger.info @Buy_id
                logger.info @Sell_id 
                if @Buy_id.price >= @Sell_id.priceexpected
                    @user_buying = User.select('cash').where(:id => @Buy_id.user_id).first
	    	        @sell_user_stock = StockUsed.select("sum(stock_useds.numofstock) as totalstock").where('stock_useds.user_id' => @Sell_id.user_id,'stock_id' => id).group("stock_id").first
                    if @user_buying.cash >= @Buy_id.price*@Buy_id.numofstock && @sell_user_stock.totalstock >= @Sell_id.numofstock
                       @stock_looper = User.stock_looper(id)  	 
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

end
