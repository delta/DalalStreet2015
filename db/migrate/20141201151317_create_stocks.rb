class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string  :stockname
      t.decimal :currentprice, precision: 4, scale: 2  
      t.decimal :dayhigh, precision: 4, scale: 2
      t.decimal :daylow, precision: 4, scale: 2
      t.decimal :alltimehigh, precision: 4, scale: 2
      t.decimal :alltimelow, precision: 4, scale: 2
      t.integer :stocksinexchange
      t.integer :stocksinmarket
      t.timestamps
    end
  end
end
