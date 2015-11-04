class Medium < ActiveRecord::Base

  belongs_to :user

  def self.add(data_media)
    create(
        url: data_media['url'],
        user_id: data_media['uid'],
        provider: data_media['provider'],
    )
  end

end
