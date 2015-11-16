class User < ActiveRecord::Base
  has_many :instruments
  has_many :genres
  has_many :influences
  has_many :mediums
  has_many :matchings


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


end
