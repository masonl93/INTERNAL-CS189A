class AddGenresToInfluences < ActiveRecord::Migration
  def change
    add_column :influences, :genres, :string
  end
end
