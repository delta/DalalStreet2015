class MarketEvent < ActiveRecord::Base
  MarketEvent.connection.clear_query_cache

  def self.new_event(id,eventname,event_type,event,event_turn,event_done)
   @create_new_market = MarketEvent.create(:stock_id => id, :eventname => eventname, :event_type => event_type, :event => event,:event_turn => event_turn, :event_done => event_done)
  end 

  def self.get_events(num)
	@get_market_event = MarketEvent.select("eventname,updated_at").last(num).reverse
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
	   @running_events.each do |market_event|
	       if market_event.event_type == 0 ##negative event
	          @stock = Stock.select("currentprice").where(:id => market_event.stock_id).first     
	          @stock.currentprice = @stock.currentprice - @stock.currentprice*0.02
	       else
	          @stock = Stock.select("currentprice").where(:id => market_event.stock_id).first     
	          @stock.currentprice = @stock.currentprice + @stock.currentprice*0.02
	       end
		   market_event.event_turn = market_event.event_turn + 1 
		   if market_event.event_turn == 3
		      market_event.event_done = 1
		   end
		   @stock.save
		   market_event.save
	       if market_event.save
	        @log = Company.custom_logger("save success")
	       end
       end      
  end ##end event_runner

end