class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :date
      t.text :description
      t.string :url
      t.string :location

      t.timestamps null: false
    end
  end
end
