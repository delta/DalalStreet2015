class AddNameToMarketEvent < ActiveRecord::Migration
  def change
  	rename_column :market_events, :event, :eventname
  	add_column    :market_events, :event, :integer
  end

  def self.down
	 remove_column :market_events, :eventname 
	 remove_column :market_events, :event
  end
end
