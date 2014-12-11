class Notification < ActiveRecord::Base
	belongs_to :user


 def self.get_notice(id,num)
	@notifications_list = Notification.select("notification,updated_at").where('user_id' => id).last(num).reverse
  return @notifications_list
 end

end
