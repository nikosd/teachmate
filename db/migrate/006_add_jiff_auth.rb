class AddJiffAuth < ActiveRecord::Migration
  def self.up
   
   add_column :users, :hashed_password, :string, :limit => 40
   add_column :users, :salt, :string, :limit => 40
   add_column :users, :openid, :string
   add_column :users, :remember_token, :string, :limit => 40
   add_column :users, :remember_token_expires_at, :datetime

   add_index :users, :email, :unique => true
   add_index :users, :openid, :unique => true

   remove_column :users, :password

  end

  def self.down
    remove_column :users, :hashed_password
    remove_column :users, :salt
    remove_column :users, :openid
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at

    remove_index :users, :email
    remove_index :users, :openid

    add_column :users, :password, :string, :limit => 32
  end
end
