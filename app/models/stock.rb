class Stock < ActiveRecord::Base
      validates :currentprice, presence: true
      
has_many :stock_useds
has_many :banks


 def self.get_total_stock_price(id) 
   @stocks = Stock.joins(:stock_useds).select("sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => id).group("stock_id")
   @price_of_tot_stock = 0
         @stocks.each do |stock| 
          @price_of_tot_stock = @price_of_tot_stock.to_f + stock.netcash.to_f
         end
   return @price_of_tot_stock.round(2)
 end

 def self.return_bought_stocks(id)
   @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => id).group("stock_id")
   return @stocks
 end

 def self.update_current_price(id,price)
     file_name = Rails.root.join('app','chart-data',id.to_s+'.log')
     if file_name.exist?
      file = File.open(file_name, "a")
     else
      file = File.new(file_name, "w+")
     end
     file.print price.round(2).to_s+","
     file.close
 end

 def self.read_current_price(id)
	file_name = Rails.root.join('app','chart-data',id.to_s+'.log')
    file = File.open(file_name, "rb")
 	price_list = file.read
 	file.close
 	return price_list.to_s
 end

end
