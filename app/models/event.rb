class Event < ActiveRecord::Base
  belongs_to :user

  def self.add(uid, t, date, descript, link, l)
    create(
        user_id: uid,
        title: t,
        date: date,
        description:descript,
        url:link,
        location:l
    )
  end
end
