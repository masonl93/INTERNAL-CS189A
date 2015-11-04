class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :genre
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
