class UsersController < ApplicationController
  def index

  end

  def new
  end

  def show
    @user = User.find(params[:id])
  end

  def create

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
  end

  def updateSurvey
    puts 'HEYYYY'
    puts params
    params[:play] = 1
    params[:uid] = session[:user_id]
    instrument = Instrument.add(params)
    genre = Genre.add(params)
    influence = Influence.add(params)
    media = Medium.add(params)
    User.update_bio(session[:user_id], params[:bio])
    redirect_to action: "show", id: session[:user_id]
  end

  # Finds a possible match for swiping
  def findMatch
    @users = User.ids       # Matching algorithm: Find all users and iterate over them
    me = User.find(session[:user_id])
    @users.each do |u|
      @user = User.find(u)
      # Checks if one user already saw me, or vice versa, and makes sure it's not self
      # If users have never seen each other, then new match is created
      # and user gets to like/dislike user
      if (!Matching.matchExists(@user.uid, me.uid) && !Matching.matchExists(me.uid, @user.uid) && @user.uid != me.uid)
        @userMatch = Matching.createMatch(@user.uid, me.uid)    # Creates the match in the database
        return
        # Checks if user has already reviewed and waiting on me
        # If match exists and the other user has already liked/disliked
        # me (hence status =1 or =-1), then me gets to like/dislike user
      elsif Matching.matchExists(me.uid, @user.uid)
        @the_match = Matching.where(:user1 => me.uid).where(:user2 => @user.uid).first()
        if (@the_match[:status] == 1 || @the_match[:status] == -1)
          return
        end
      end
    end
    # gone through all user options
    render "no_new_users"
  end

  def notify_user_match
    redirect_to action: "view_matches"
  end

  def init_message

  end

  # Updates Matching object after user clicks yes or no on another user
  def matchChoice
    user = params[:uid]
    me = User.find(session[:user_id])

    # Find the correct match between the two users
    if Matching.where(user1: user, user2: me.uid).exists?
      @the_match = Matching.where(:user1 => user).where(:user2 => me.uid).first()
    else
      @the_match = Matching.where(:user1 => me.uid).where(:user2 => user).first()
    end

    # Checking if the like button or dislike button was pressed
    # in order to properly update status value
    if params.has_key?(:like)
      @the_match.increment!(:status)
    elsif params.has_key?(:dislike)
      @the_match.decrement!(:status)
    end

    # Check to see if we have a match
    if @the_match[:status] == 2
      # we have a match
      start_message = notify_user_match
      if start_message
        redirect_to action: "init_message"
      else
        redirect_to action: "findMatch"
      end
    end
    redirect_to action: "findMatch"
  end


  def view_matches
    me = User.find(session[:user_id])
    @matches = Matching.where("(user1 = ? OR user2 = ?) AND status = ?", me.uid, me.uid, 2)
    @matched_users = []
    @matches.each do |match|
      if match.user1 == me.uid
        user = User.where(:uid => match.user2).first()
      else
        user = User.where(:uid => match.user1).first()
      end
      @matched_users << user
    end
  end


  def showMatches
    @users = User.all

  end

  def destroy

  end

end


