class CreateLearnTaggings < ActiveRecord::Migration
  def self.up
    create_table :learn_taggings do |t|
			t.column :tag_id, :integer
      t.timestamps
    end
		create_table :learn_taggings_users do |t|
			t.column :learn_tagging_id, :integer
			t.column :user_id, :integer
		end
  end

  def self.down
    drop_table :learn_taggings
    drop_table :learn_taggings_users
  end
end
