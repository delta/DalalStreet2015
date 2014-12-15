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
  	  event_type = [0,1].sample(1)
      event =  [1,2,3].sample(1)
      
      event_selector(event_type,event)
  end

  def self.event_selector(event_type,event)
    if event_type
      case event # a_variable is the variable we want to compare
		when 1    #compare to 1
		  puts "it was 1" 
		when 2    #compare to 2
		  puts "it was 2"
		else
		  puts "it was something else"
        end
    else
      case event # a_variable is the variable we want to compare
		when 1    #compare to 1
		  puts "it was 1" 
		when 2    #compare to 2
		  puts "it was 2"
		else
		  puts "it was something else"
        end
    end
  end


end ## end of class def
