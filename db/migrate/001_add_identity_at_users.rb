class AddIdentityAtUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mojeid_identity_url, :string
  end

  def self.down
    remove_column :users, :mojeid_identity_url
  end
end
