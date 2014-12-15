class Company < ActiveRecord::Base
  @queue = :company
  def self.perform()
    a =  [+2,+2].sample(1)
    @current_price_vary = Stock.first
    @current_price_vary.currentprice = @current_price_vary.currentprice + a[0]
    puts @current_price_vary.stockname
    puts @current_price_vary.currentprice
    @current_price_vary.save
    @call_update_stock_user = SocketController.call_update_stock_user
  end
end
