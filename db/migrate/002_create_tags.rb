class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :string, :limit => 256
      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
