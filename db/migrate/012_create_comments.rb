class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column    :body, :string, :limit => 10000
      t.column    :user_id, :integer
      t.column    :author_id, :integer
      t.timestamps
    end
    add_index :comments, [:user_id, :author_id], :unique => true, :name => 'user_author'
  end

  def self.down
    drop_table :comments
  end
end
