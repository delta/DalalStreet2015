class Stock < ActiveRecord::Base

has_many :stock_useds


 def self.get_total_stock_price(id) 
   @stocks = Stock.joins(:stock_useds).select("sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => id).group("stock_id")
   @price_of_tot_stock = 0
         @stocks.each do |stock| 
          @price_of_tot_stock = @price_of_tot_stock + stock.netcash.to_f
         end

   return @price_of_tot_stock
 end

end
