class AddCashToUsers < ActiveRecord::Migration
  def change
  add_column :users, :cash, :decimal, precision: 6, scale: 2  
  end
end
