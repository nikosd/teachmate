class AddUserId < ActiveRecord::Migration
  def self.up
   drop_table :teach_taggings_users
   drop_table :learn_taggings_users
   
   add_column :learn_taggings, :user_id, :integer
   add_column :teach_taggings, :user_id, :integer

  end

  def self.down
  end
end
