class AddEventFinish < ActiveRecord::Migration
  def change
  	add_column :market_events, :event_done, :integer
  end

  def self.down
	 remove_column :market_events, :event_done 
  end
end
