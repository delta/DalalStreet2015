class Company < ActiveRecord::Base
  @queue = :company

  def self.perform()
    ############# perform company events only after every 3 cyles ##############################################################
    # @call_event_company = Company.Company_event

    @call_event_company_all = Company.All_Company_event
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
	       stock.daylow = stock.currentprice.to_f
        end
	    if stock.dayhigh.to_f < stock.currentprice.to_f
	       stock.dayhigh = stock.currentprice.to_f
	    end
	    stock.save
      end
  end


#################################################### modified version ################################################################################
  def self.All_Company_event
     @stocks = Stock.all
     @stocks.each do |stock|
       @event_selector_all = Company.event_selector_all(stock)
     end  
  end

  def self.event_selector_all(stock)

    event_type = [0,1].sample
    event =  [1,2,3].sample

    if event_type == 0 ##negative events
      case event
    when 1    
       variation = ["reports quaterly loss in revenue","faces lawsuit for illegal patent frauds"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}" 
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    when 2  
       eventname = "CEO of #{stock.stockname} sacked" 
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    else
       @acquired = MarketEvent.acquire(stock.id,event_type,event) 
      end
    else ## positive events
      case event 
    when 1    
       variation = ["reports higher profit margins","set to expand globally"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"  
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    when 2    
       variation = ["releases new products for holiday season","set to invest on the latest tech"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"  
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    else
       variation = ["plans to split stocks"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"  
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
      end
    end
  end## end of event_selector

#################################################### modified version ################################################################################

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
    if event_type == 0 ##negative events
      case event
		when 1    
		  variation = ["reports quaterly loss in revenue","faces lawsuit for illegal patent frauds"].sample
		  random_partial_event = variation.to_s
		  eventname = "#{@stock.stockname} #{random_partial_event}" 
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		when 2  
		  eventname = "CEO of #{@stock.stockname} sacked" 
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		else
		  @acquired = MarketEvent.acquire(@stock.id,event_type,event) 
      end
    else ## positive events
      case event 
		when 1    
		  variation = ["reports higher profit margins","set to expand globally"].sample
          random_partial_event = variation.to_s
          eventname = "#{@stock.stockname} #{random_partial_event}"  
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		when 2    
		  variation = ["releases new products for holiday season","set to invest on the latest tech"].sample
		  random_partial_event = variation.to_s
		  eventname = "#{@stock.stockname} #{random_partial_event}"  
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
		else
		  variation = ["plans to split stocks"].sample
		  random_partial_event = variation.to_s
		  eventname = "#{@stock.stockname} #{random_partial_event}"  
	      @create_event = MarketEvent.new_event(@stock.id,eventname,@event_type,@event,0,0)
      end
    end
  end## end of event_selector

end ## end of class def