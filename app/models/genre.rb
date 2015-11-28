class Genre < ActiveRecord::Base
  belongs_to :user

  def self.add(genre, uid)
    create(
        genre: genre,
        user_id: uid,
    )
  end

end
