class AddColToLog < ActiveRecord::Migration
  def change
  	add_column :logs, :user_id, :integer
  	add_column :logs, :stock_id, :integer
  	add_column :logs, :log, :string
  	
  end

  def self.down
	 remove_column :logs, :user_id 
	 remove_column :logs, :stock_id 
  end
end
