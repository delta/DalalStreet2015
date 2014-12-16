class CreateMarketEvents < ActiveRecord::Migration
  def change
    create_table :market_events do |t|
      t.integer :stock_id
      t.string  :event
      t.integer :event_type
      t.integer :event_turn
      t.timestamps
    end
  end
end
