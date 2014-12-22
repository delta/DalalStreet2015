class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.integer :user_id
      t.integer :stock_id
      t.decimal :pricerendered
      t.integer :numofstock
      t.timestamps
    end
  end
end
