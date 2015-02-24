class AddTotalToUsers < ActiveRecord::Migration
  def change
   add_column :users, :total, :decimal, :precision => 8, :scale => 3, :null => false, :default => "10000.00"
  end
end
