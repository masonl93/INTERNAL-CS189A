class Instrument < ActiveRecord::Base
  belongs_to :user

  def self.add(data_instrument)
    create(
        instrument: data_instrument['instrument'],
        experience: data_instrument['exp'],
        play: data_instrument['play'],
        user_id: data_instrument['uid'],
    )
  end

end
