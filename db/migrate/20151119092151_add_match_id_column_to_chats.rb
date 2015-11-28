class AddMatchIdColumnToChats < ActiveRecord::Migration
  def change
    add_column :chats, :match_id, :integer
  end
end
