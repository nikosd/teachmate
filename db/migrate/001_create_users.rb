class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      
      #general info
      t.string  :password, :limit => 32
      t.string  :email
      
      #personal
      t.string  :first_name,  :limit  => 32
      t.string  :second_name, :limit => 32
      t.date    :birthdate

      #location
      t.string  :city,    :limit => 32
      t.string  :region,  :limit => 32
      t.string  :country, :limit => 32

      #other
      t.string  :notes
      t.integer :rating

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
