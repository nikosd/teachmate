class AddPasswordToken < ActiveRecord::Migration
  def self.up
    add_column :users, :password_token,         :string, :unique => true, :limit => 20
    add_column :users, :password_token_expires, :datetime
  end

  def self.down
    remove_column :users, :password_token
    remove_column :users, :password_token_expires
  end
end
