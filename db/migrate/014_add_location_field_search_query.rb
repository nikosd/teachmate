class AddLocationFieldSearchQuery < ActiveRecord::Migration
  def self.up
    add_column :search_queries, :location, :string, :limit => 100
    remove_index :search_queries, [:learn_string, :teach_string]
    add_index(
      :search_queries,
      [:learn_string, :teach_string, :location],
      :unique => true, 
      :name => 'learn_teach_location'
    )
  end

  def self.down
    remove_index :search_queries, 'learn_teach_location'
    add_index :search_queries, [:learn_string, :teach_string], :unique => true
    remove_column :search_queries, :location
  end
end
