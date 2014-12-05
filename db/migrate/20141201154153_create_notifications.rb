class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string  :notification
      t.integer :seen
      t.integer :type
      t.timestamps
    end
  end
end
