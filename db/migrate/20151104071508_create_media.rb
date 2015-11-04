class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :url
      t.integer :user_id
      t.string :provider

      t.timestamps null: false
    end
  end
end
