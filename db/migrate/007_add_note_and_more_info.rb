class AddNoteAndMoreInfo < ActiveRecord::Migration
  def self.up
    remove_column :users, :notes
    add_column :users, :notes, :string, :limit => 100
    add_column :users, :more_info, :text
  end

  def self.down
    remove_column :users, :notes
    remove_column :users, :more_info
    add_column :users, :notes, :string
  end
end
