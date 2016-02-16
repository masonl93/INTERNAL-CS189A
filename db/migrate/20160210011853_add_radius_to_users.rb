class AddRadiusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :radius, :float
  end
end
