class CreateSells < ActiveRecord::Migration
  def change
    create_table :sells do |t|
      t.integer :user_id
      t.integer :stock_id
      t.decimal :priceexpected
      t.integer :numofstock
      t.timestamps
    end
  end
end
