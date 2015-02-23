class AddTotalToUsers < ActiveRecord::Migration
  def change
   add_column :users, :total, :decimal, :precision => 8, :scale => 3
  end
end
