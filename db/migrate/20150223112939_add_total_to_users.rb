class AddTotalToUsers < ActiveRecord::Migration
  def change
   add_column :users, :total, :decimal, :precision => 6, :scale => 2
  end
end
