class Genre < ActiveRecord::Base
  belongs_to :user

  def self.add(data_genre)
    create(
        genre: data_genre['genre'],
        user_id: data_genre['uid'],
    )
  end

end
