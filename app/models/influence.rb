class Influence < ActiveRecord::Base
  belongs_to :user

  def self.add(data_influence)
    create(
        influence: data_influence['influence'],
        user_id: data_influence['uid'],
    )
  end

end
