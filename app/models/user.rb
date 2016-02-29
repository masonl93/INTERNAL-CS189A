class User < ActiveRecord::Base
  acts_as_messageable


  has_many :instruments
  has_many :genres
  has_many :influences
  has_many :mediums
  has_many :matchings
  has_many :chats, dependent: :delete_all
  has_many :groups, dependent: :delete_all
  has_many :events

  def self.sign_in_from_omniauth(auth)
    find_by(provider: auth['provider'], uid: auth['uid']) || create_user_from_omniauth(auth)
  end

  def self.create_user_from_omniauth(auth)
    create(
        provider: auth['provider'],
        uid: auth['uid'],
        name: auth['info']['name'],
        image: auth['info']['image'],
        email: auth['info']['email']
    )
  end

  def self.update_bio(uid, bio)
    user = self.find(uid)
    user.bio = bio
    user.save
  end

  def self.update_radius(uid, radius)
    user = self.find(uid)
    user.radius = radius
    user.save
  end

  def self.getDistance(loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    return rm * c # Delta in meters
  end

  # Add function to add interest_level
  def self.update_interest_level(uid, interest_level)
    user = self.find(uid)
    user.interest_level = interest_level
    user.save

  end

end
