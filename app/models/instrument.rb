class Instrument < ActiveRecord::Base
  belongs_to :user

  def self.add(inst, exper, plays, uid)
    create(
        instrument: inst,
        experience: exper,
        play: plays,
        user_id: uid,
    )
  end

end
