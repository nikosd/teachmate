class SearchQueriesTable < ActiveRecord::Migration
  def self.up
    create_table :search_queries do |t|
      t.string :learn_string
      t.string :teach_string
    end
    add_index :search_queries, [:learn_string, :teach_string], :name => 'learn_teach', :unique => true
  end

  def self.down
    drop_table :search_queries
  end
end
