class AddUpDownToStocks < ActiveRecord::Migration
  def change
  	add_column :stocks, :updown, :integer
  end
end
