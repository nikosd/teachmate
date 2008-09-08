class CreateTeachTaggings < ActiveRecord::Migration
  def self.up
    create_table :teach_taggings do |t|
			t.column :tag_id, :integer
      t.timestamps
    end
		create_table :teach_taggings_users do |t|
			t.column :teach_tagging_id, :integer
			t.column :user_id, :integer
		end
  end

  def self.down
    drop_table :teach_taggings
		drop_table :teach_taggings_users
  end
end
