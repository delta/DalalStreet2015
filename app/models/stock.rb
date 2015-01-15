class Stock < ActiveRecord::Base
      # validates :currentprice, presence: true
      
has_many :stock_useds
has_many :banks


 def self.get_total_stock_price(id) 
   @stocks = Stock.joins(:stock_useds).select("sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => id).group("stock_id")
   @price_of_tot_stock = 0

   if !@stocks.blank?
      @stocks.each do |stock| 
        @price_of_tot_stock = @price_of_tot_stock.to_f + stock.netcash.to_f
      end
      return @price_of_tot_stock.round(2)
   else
      return 0
   end   
 end

 def self.return_bought_stocks(id)
   @stocks = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => id).group("stock_id")
   return @stocks
 end

 def self.return_stock_user_first(user)
   @stock = Stock.joins(:stock_useds).select("stocks.*,sum(stock_useds.numofstock) as totalstock,sum(stock_useds.numofstock)*stocks.currentprice as netcash").where('stock_useds.user_id' => user).group("stock_id").first
   if @stock.blank?
     return nil
   else
     return @stock
   end
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
    if file_name.exist?
     file = File.open(file_name, "rb")
     price_list = file.read
     file.close
  	else 
     file = File.new(file_name, "w+")
     @stock = Stock.select(:currentprice).where(:id => id).first
     file.print @stock.currentprice.round(2).to_s+","
     file.close
    end
   	return price_list.to_s
 end

end
