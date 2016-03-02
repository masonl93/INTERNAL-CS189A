class Matching < ActiveRecord::Base
  belongs_to :user

  # 0 = Initialized
  # 1 = user 1 liked user 2
  # 2 = user 2 liked user 1
  # 3 = both users liked
  # -1 = user 1 disliked user 2
  # -2 = user 2 disliked user 1
  # -3 = both users disliked

  def self.matchExists(user_1id, user_2id)
    #if exists?(user1: user_1, user2: user_2) ||  exists?(user1: user_2, user2: user_1)
    if exists?(user1: user_1id, user2: user_2id)
      return true
    elsif exists?(user1: user_2id, user2: user_1id)
      return true
    else
      return false
    end
  end
  
  def self.getAllMatches(myID)
    matches = []
    where('user1 = ?', myID).each do |match|
      if match.status == 3
        matches.append(match.user2.to_i)
      end
    end
    where('user2 = ?', myID).each do |match|
      if match.status == 3
        matches.append(match.user1.to_i)
      end
    end
    return matches
  end

  def self.createMatch(user_1id, user_2id, choiceNum)
    # User 2 created match, first user to like/dislike other user
    create(
        user1: user_1id,
        user2: user_2id,
        status: choiceNum
    )
  end

  def self.ifElligible(myID, user)
    first = [-3, -1, 1, 3]
    second = [-3, -2, 2, 3]
    usrID = user.id.to_s
    if exists?(user1: myID, user2: usrID)
      record =  where(user1: myID, user2: usrID).first!
      if first.include? record.status
        return false
      else
        return true
      end
    elsif exists?(user1: usrID, user2: myID)
      record =  where(user1: usrID, user2: myID).first!
      if second.include? record.status
        return false
      else
        return true
      end
    else
      return true
    end
  end

  def self.updateLikeStatus(matchRecord, curID, usrID)
    if matchRecord.user1 == usrID
      if matchRecord.status == 1
        matchRecord.status = 3
      elsif matchRecord.status == -1
        matchRecord.status = 2
      end
    elsif matchRecord.user2 == usrID
      if matchRecord.status == 2
        matchRecord.status = 3
      elsif matchRecord.status == -2
        matchRecord.status = 1
      end
    end
    matchRecord.save
    return matchRecord
  end

  def self.updateDislikeStatus(matchRecord, curID, usrID)
    if matchRecord.user1 == usrID
      if matchRecord.status == -1
        matchRecord.status = -3
      else
        matchRecord.status = -2
      end
    elsif matchRecord.user2 == usrID
      if matchRecord.status == -2
        matchRecord.status = -3
      else
        matchRecord.status = -1
      end
    end
    matchRecord.save
    return matchRecord
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

  def self.getInfluencePoints(myInfluences, userInfluences)
    if myInfluences.length == 0 || userInfluences.length == 0
      return 10
    end
    score = 0
    me = []
    #puts myInfluences
    myInfluences.each do |i|
      genre = i.genres
      me += genre.split(",")
    end

    userInfluences.each do |u|
      genre = u.genres
      genre.split(",").each do |g|
        if me.include? g
          score += 5
        end
      end
    end
    return score
  end
end
