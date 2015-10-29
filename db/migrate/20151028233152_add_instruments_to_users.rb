class AddInstrumentsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guitar, :integer
    add_column :users, :bass, :integer
    add_column :users, :drum, :integer
    add_column :users, :sing, :integer
  end
end
