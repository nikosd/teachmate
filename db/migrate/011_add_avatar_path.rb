class AddAvatarPath < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar, :string, :unique => true
  end

  def self.down
    remove_columns :users, :avatar
  end
end
