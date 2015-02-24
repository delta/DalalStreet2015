module IndexHelper
  
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def image_loader
    @stock_names = []
    @market_events_paginate = MarketEvent.order('created_at DESC').limit(15).offset(0)
    @market_events_paginate = @market_events_paginate.sample(7)
	
	  @market_events_paginate.each do |event|
      @find_stock = Stock.where(:id => "#{event.stock_id}").first
      @stock_names.push(@find_stock.stockname+[1,2,3,4].sample.to_s)
    end
    
    return @stock_names    
  end

end
