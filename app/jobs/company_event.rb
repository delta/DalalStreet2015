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
    event =  [1,2,3,4].sample

    logger.info event_type
    logger.info event
    logger.info stock

   if event_type == 0 ##negative events
      case event
    when 1    
       variation = ["reports quaterly loss in revenue","faces lawsuit for illegal patent frauds"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}" 
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    when 2  
       variation = ["Analysts predict a dip in #{stock.stockname}'s share value","CEO of #{stock.stockname} sacked"].sample
       eventname = variation.to_s
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    when 3
       variation = ["network hacked and compromised","employees calls for a strike"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    else
       random_num = [10,12,25,17].sample
       random_country = ["India","China","Brazil","USA","Canada"].sample
       variation = ["reduces its global workforce by #{random_num}%","acquires assets in #{random_country}"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    end
   else ## positive events
      case event 
    when 1    
       variation = ["reports higher profit margins","set to expand globally"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"  
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    when 2 
       random_num = [20,40,75,120].sample   
       variation = ["releases new products for holiday season","set to invest #{random_num} million on latest tech"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    when 3
       variation = ["capital boosted by new foreign policies","plans to split stocks"].sample
       random_partial_event = variation.to_s
       eventname = "#{stock.stockname} #{random_partial_event}"  
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    else
       variation = ["New government policy helping #{stock.stockname}'s growth","#{stock.stockname} beats analysts prediction"].sample
       eventname = variation.to_s
       @create_event = MarketEvent.new_event(stock.id,eventname,event_type,event,0,0)
    end

   end
  end## end of event_selector

#################################################### modified version ################################################################################

end