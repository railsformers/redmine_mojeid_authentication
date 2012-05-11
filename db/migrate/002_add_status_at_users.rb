class AddStatusAtUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mojeid_status, :string
  end

  def self.down
    remove_column :users, :mojeid_status
  end
end
