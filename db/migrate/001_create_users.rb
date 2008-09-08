class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      
      #general info
      t.string  :password, :limit => 32
      t.string  :email
      
      #personal
      t.string  :first_name
      t.string  :second_name
      t.date    :birthdate

      #location
      t.string  :city
      t.string  :region
      t.string  :country

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
