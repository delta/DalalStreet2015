class AddCashToUsers < ActiveRecord::Migration
  def change
  add_column :users, :cash, :decimal, :precision => 8, :scale => 3, :null => false, :default => "10000.00"
  end
end
