class CreateBuys < ActiveRecord::Migration
  def change
    create_table :buys do |t|
      t.integer :user_id
      t.integer :stock_id
      t.decimal :price
      t.integer :numofstock
      t.timestamps
    end
  end
end
