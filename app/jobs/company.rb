class Company < ActiveRecord::Base
  @queue = :company


  def self.perform()
    @call_event_company = Company.Company_event
    @update_statistics = Company.update_statistics
    @call_event_runner = MarketEvent.event_runner
    @call_update_stock_user = SocketController.call_update_stock_user
  end


  def self.custom_logger(log)
     fname = Rails.root.join('log','market_event.log')
     somefile = File.open(fname, "a")
     time = Time.now
     somefile.puts "time::"+time.to_s+"  "+log+ "\n"
     somefile.close
  end


  def self.update_statistics
    @current_price_vary = Stock.all
      @current_price_vary.each do |stock|
	    if stock.daylow.to_f > stock.currentprice.to_f
	       stock.daylow = stock.currentprice
        end
	    if stock.dayhigh.to_f < stock.currentprice.to_f
	       stock.dayhigh = stock.currentprice
	    end
	    stock.save
      end
  end


  def self.Company_event
    @event_type = [0,1].sample
    @event =  [1,2,3].sample
    @random_id = MarketEvent.distil
    if @random_id !=0	
       @stock = Stock.where('id' => @random_id).first
       @event_selector = Company.event_selector(@event_type,@event)
    else
       @log = Company.custom_logger("event_selector cancelled")
    end   
  end


  def self.event_selector(event_type,event)
  	puts event_type
  	puts event
    if event_type == 0 ##negative events
      case event
		when 1    
		  variation = ["reports quaterly loss in revenue","faces lawsuit for illegal patent frauds"].sample(1)
		  eventname = "#{@stock.stockname} #{variation}" 
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		when 2  
		  eventname = "CEO of #{@stock.stockname} sacked" 
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		else
		  @acquired = MarketEvent.acquire(@stock.id,@event_type) 
      end
    else ## positive events
      case event 
		when 1    
		  variation = ["reports higher profit margins","set to expand globally"].sample(1)
          eventname = "#{@stock.stockname} #{variation}"  
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		when 2    
		  variation = ["releases new products for holiday season","set to invest on the latest tech"].sample(1)
		  eventname = "#{@stock.stockname} #{variation}"  
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		else
		  variation = ["plans to split stocks"].sample(1)
		  eventname = "#{@stock.stockname} #{variation}"  
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
      end
    end
  end## end of event_selector


end ## end of class def