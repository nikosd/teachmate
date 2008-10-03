class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column   :user_id, :integer
      t.column   :recipient_id, :integer
      t.column   :body, :string, :limit => 5000
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
