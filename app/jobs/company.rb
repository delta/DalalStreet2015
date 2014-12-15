class Company < ActiveRecord::Base
  @queue = :company

  def self.perform()
    
    @current_price_vary = Stock.all
    @current_price_vary.each do |stock|
	    a =  [+1,-1].sample(1)
	    stock.currentprice = stock.currentprice + a[0]
	    if stock.daylow.to_f > stock.currentprice.to_f
	    	stock.daylow = stock.currentprice
        end
	    if stock.dayhigh.to_f < stock.currentprice.to_f
	        stock.dayhigh = stock.currentprice
	    end     	
	    #puts @current_price_vary.stockname
	    #puts stock.currentprice
	    stock.save
    end
    @call_update_stock_user = SocketController.call_update_stock_user
  end


  def self.Company_event()
  




  end

end
