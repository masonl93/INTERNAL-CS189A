class CreateInstruments < ActiveRecord::Migration
  def change
    create_table :instruments do |t|
      t.string :instrument
      t.integer :user_id
      t.integer :experience
      t.boolean :play

      t.timestamps null: false
    end
  end
end
