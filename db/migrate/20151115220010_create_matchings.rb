class CreateMatchings < ActiveRecord::Migration
  def change
    create_table :matchings do |t|
      t.string :user1
      t.string :user2
      t.integer :status

      t.timestamps null: false
    end
  end
end
