class CreateInstrumentChoices < ActiveRecord::Migration
  def change
    create_table :instrument_choices do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
