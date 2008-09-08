class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.column :user_id,          :integer
      t.column :search_query_id,  :integer
      t.timestamps
    end
    add_index :subscriptions, [:user_id, :search_query_id], :unique => true
  end

  def self.down
    drop_table :subscriptions
  end
end
