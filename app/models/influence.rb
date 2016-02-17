class Influence < ActiveRecord::Base
  belongs_to :user

  def self.add(i, uid, genres)
    create(
        influence: i,
        user_id: uid,
        genres: genres,
    )
  end

end
