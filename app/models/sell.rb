class Sell < ActiveRecord::Base

	 belongs_to :user
     belongs_to :stock

  def self.get_sell_history (id,num)
      @sell_history = Sell.select("stock_id,numofstock,priceexpected").where('stock_id' => id).last(num).reverse
      if @sell_history.blank?
         return nil
      else
         return @sell_history
      end   
  end 
     
end
