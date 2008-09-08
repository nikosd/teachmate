class AddNoteAndMoreInfo < ActiveRecord::Migration
  def self.up
    rename_column :users, :notes, :more_info
    add_column :users, :notes, :string, :limit => 100
  end

  def self.down
    remove_column :users, :notes
    rename_column :users, :more_info, :notes
  end
end
