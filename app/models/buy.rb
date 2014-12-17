class Buy < ActiveRecord::Base

	 belongs_to :user
     belongs_to :stock

end
