class User < ActiveRecord::Base
  validates_presence_of :uid

  def self.sign_in_from_omniauth(auth)
    puts auth
    find_by(uid: auth['uid']) || create_user_from_omniauth(auth)
  end

  def self.create_user_from_omniauth(auth)
    create(
        uid: auth['uid'],
        name: auth['info']['name'],
        email: auth['info']['email']
    )
  end

end
