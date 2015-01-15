class Buy < ActiveRecord::Base

	 belongs_to :user
     belongs_to :stock

 
  def self.get_buy_history (id,num)
      @buy_history = Buy.select("stock_id,numofstock,price").where('stock_id' => id).last(num).reverse
      if @buy_history.blank?
         return nil
      else
         return @buy_history
      end   
  end 

end
