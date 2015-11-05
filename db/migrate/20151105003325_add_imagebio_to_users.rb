class AddImagebioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image, :string
    add_column :users, :bio, :text
  end
end
