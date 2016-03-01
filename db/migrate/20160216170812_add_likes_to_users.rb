class AddLikesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_likes, :int
  end
end
