class StockUsed < ActiveRecord::Base

	belongs_to :stocks
	has_many :users


	

end
