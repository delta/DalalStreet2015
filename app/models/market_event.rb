class MarketEvent < ActiveRecord::Base
  MarketEvent.connection.clear_query_cache
  

  def self.new_event(id,eventname,event_type,event,event_turn,event_done)
    if !id.blank?
     @create_new_market = MarketEvent.create(:stock_id => id, :eventname => eventname, :event_type => event_type, :event => event,:event_turn => event_turn, :event_done => event_done)
    end
  end 

  def self.get_events(num,id)
	@get_market_event = MarketEvent.select("eventname,updated_at").where(:stock_id => id).last(num).reverse
  end

  def self.distil
    @market_ids = MarketEvent.where("event_done" => 0).uniq.pluck(:stock_id) 
    puts "market_ids"
    puts @market_ids
    puts " " 	
    @stock_ids = Stock.pluck(:id)
    @filtered_ids = @stock_ids - @market_ids
    puts "filtered_ids"
    puts @filtered_ids
    if @filtered_ids.blank?
       @log = Company.custom_logger("All companies occupied with events")
       @random_id = 0
    else
       @random_id = @filtered_ids.sample
    end
    return @random_id 
  end

  def self.acquire(id,event_type,event)
    @stock = Stock.where("stocks.id" => id).first
    @market_stock = MarketEvent.select("stock_id").where("event_done" => 1,"event_type" => 0).order("RANDOM()").first
    
    loop do 
     @market_stock = MarketEvent.select("stock_id").where("event_done" => 1,"event_type" => 0).order("RANDOM()").first
    break if id != @market_stock.stock_id
    end 

    if !@market_stock.blank?
	    @acquired_stock =  Stock.where(:id => @market_stock.stock_id).first
	    eventname1 = "#{@stock.stockname} acquires #{@acquired_stock.stockname}"
	    eventname2 = "#{@acquired_stock.stockname} acquired by #{@stock.stockname}"
		@create_event = MarketEvent.new_event(@stock.id,eventname1,0,event,0,0)
		@create_event = MarketEvent.new_event(@acquired_stock.id,eventname2,1,event,0,0)   	
    else
        @log = Company.custom_logger("No acquire company found")
    end
  end ##acquire def end

  def self.event_runner
    @running_events = MarketEvent.where("event_done" => 0).all
    if !@running_events.blank?
  	   @running_events.each do |market_event|
  	       if market_event.event_type == 0 ##negative event
  	          @stockname = Stock.select("*").where(:id => market_event.stock_id).first     
  	          @stockname.currentprice = @stockname.currentprice.to_f - @stockname.currentprice.to_f*[0.01,0.02,0.025,0.013,0.032].sample
              @stockname.updown = 0
              @update_currentprice_files = Stock.update_current_price(@stockname.id,@stockname.currentprice)
  	       else
  	          @stockname = Stock.select("*").where(:id => market_event.stock_id).first     
  	          @stockname.currentprice = @stockname.currentprice.to_f + @stockname.currentprice.to_f*[0.021,0.018,0.035,0.014,0.012].sample
              @stockname.updown = 1
              @update_currentprice_files = Stock.update_current_price(@stockname.id,@stockname.currentprice)
  	       end
  		   market_event.event_turn = market_event.event_turn + 1 
  		   if market_event.event_turn == 3
  		      market_event.event_done = 1
  		   end
  		   @stockname.save
  		   market_event.save
  	       if market_event.save
  	        @log = Company.custom_logger("save success")
  	       end
         end
    else
      @log = Company.custom_logger("No event companies found");
    end           
  end ##end event_runner

end
