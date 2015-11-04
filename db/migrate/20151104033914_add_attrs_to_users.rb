class AddAttrsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :lat, :decimal
    add_column :users, :long, :decimal
    add_column :users, :age, :integer
  end
end
