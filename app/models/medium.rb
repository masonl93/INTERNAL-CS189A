class Medium < ActiveRecord::Base

  belongs_to :user

  def self.add(data_media, source)
    if source == 'youtube'
      bad_url = data_media['url']
      url_arr = bad_url.split('=', 2)
      url_id = url_arr[1].split('&', 2)
      embeded_url = "https://www.youtube.com/embed/"
      embeded_url = embeded_url + url_id[0]
      create(
          url: embeded_url,
          user_id: data_media['uid'],
          provider: source,
      )
    elsif source == 'soundcloud'
      client = Soundcloud.new(:client_id => 'fe90ab80d6ac76b5e508ff3c0a40aca6')
      track_url = data_media['url']
      embeded_info = client.get('/oembed', :url => track_url)
      data = embeded_info['html'].split('src="', 2)
      embeded_url = data[1].split('">', 2)
      create(
          url: embeded_url[0],
          user_id: data_media['uid'],
          provider: source,
      )
    end
  end
end

