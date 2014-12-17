class CreateStockUseds < ActiveRecord::Migration
  def change
    create_table :stock_useds do |t|
      t.integer :user_id
      t.integer :stock_id
      t.integer :numofstock
      t.timestamps
    end
  end
end
