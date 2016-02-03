class AddInterestLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :interest_level, :string
  end
end
