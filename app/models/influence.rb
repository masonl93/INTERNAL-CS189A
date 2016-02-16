class Influence < ActiveRecord::Base
  belongs_to :user

  def self.add(i, uid)
    create(
        influence: i,
        user_id: uid,
    )
  end

end
