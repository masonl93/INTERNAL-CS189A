class Medium < ActiveRecord::Base

  belongs_to :user

  def self.add(data_media)
    bad_url = data_media['url']
    url_arr = bad_url.split('=', 2)
    url_id = url_arr[1].split('&', 2)
    ### need to fix, link must have embeded in it for youtube
    # make soundcloud work also
    embeded_url = "https://www.youtube.com/embed/"
    embeded_url = embeded_url + url_id[0]
    create(
        url: embeded_url,
        user_id: data_media['uid'],
        provider: data_media['provider'],
    )
  end

end
