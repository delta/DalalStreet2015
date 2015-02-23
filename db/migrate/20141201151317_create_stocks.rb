class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string  :stockname
      t.decimal :currentprice, precision: 8, scale: 3  
      t.decimal :dayhigh, precision: 8, scale: 3
      t.decimal :daylow, precision: 8, scale: 3
      t.decimal :alltimehigh, precision: 8, scale: 3
      t.decimal :alltimelow, precision: 8, scale: 3
      t.integer :stocksinexchange
      t.integer :stocksinmarket
      t.timestamps
    end
  end
end
