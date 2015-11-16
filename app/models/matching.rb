class Matching < ActiveRecord::Base
    belongs_to :user
    
    def self.matchExists(user_1, user_2)
        if exists?(user1: user_1, user2: user_2) ||  exists?(user1: user_2, user2: user_1)
            return true
        else
            return false
        end
    end
    
    def self.createMatch(user_1, user_2)
        create(
            user1: user_1,
            user2: user_2,
            status: 0       # 0 = Initialized  
                            # 1 = Liked_user
                            # 2 = Match :)
                            # 3 = Denied
    )
    end

end
