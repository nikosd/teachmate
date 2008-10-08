class AddNoteAndMoreInfo < ActiveRecord::Migration
  def self.up
    remove_column :users, :notes, :more_info
    add_column :users, :notes, :string, :limit => 100
    add_column :users, :more_info, :text, :limit => 100
  end

  def self.down
    remove_column :users, :notes
    remove_column :users, :more_info
    add_column :users, :notes, :string
  end
end
