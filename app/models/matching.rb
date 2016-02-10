class Matching < ActiveRecord::Base
  belongs_to :user

  def self.matchExists(user_1, user_2)
    #if exists?(user1: user_1, user2: user_2) ||  exists?(user1: user_2, user2: user_1)
    if exists?(user1: user_1, user2: user_2)
      return true
    else
      return false
    end
  end

  def self.createMatch(user_1, user_2)
    # User 2 created match, first user to like/dislike other user
    create(
        user1: user_1,
        user2: user_2,
        status: 0       # 0 = Initialized
    # 1 = Liked_user
    # 2 = Match :)
    # 3 = Denied
    )
  end

  def self.getInstrumentAndExperiencePoints(myLookingForInstruments, userPlays,  myInstruments, userWants)
    score = 0
    userPlays.each do |inst|
      if myLookingForInstruments.include? inst.instrument
        score += 20
        score += 5 * inst.experience
      end
    end

    userWants.each do |inst|
      if myInstruments.include? inst.instrument
        score += 10
      end
    end
    return score
  end

  def self.getGenrePoints(myGenres, userGenre)
    score = 0
    userGenre.each do |g|
      if myGenres.include? g.genre
        score += 15
      end
    end
    return score
  end
end
