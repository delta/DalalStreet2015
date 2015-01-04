class CompanyEvent < ActiveRecord::Base
  @queue = :company_event

  def self.perform()
    @call_event_company_all = CompanyEvent.All_Company_event
    @call_update_stock_user = SocketController.call_update_stock_user
  end

#################################################### modified version ################################################################################
  def self.All_Company_event
     @stocks = Stock.all
     @stocks.each do |stock|
       @event_selector_all = CompanyEvent.event_selector_all(stock)
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


end