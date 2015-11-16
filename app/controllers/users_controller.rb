class UsersController < ApplicationController
  def index

  end

  def new
  end

  def show
    @user = User.find(session[:user_id])
  end

  def create

  end

  def edit
    @user = User.find(session[:user_id])
    puts 'at param1~~~~~~~~~~~~~~'
    puts params
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
    @user = User.order("RANDOM()").first        # Matching algorithm: Find random user
    me = User.find(session[:user_id])
    if (!Matching.matchExists(@user.uid, me.uid) && @user.uid != me.uid)
        @userMatch = Matching.createMatch(@user.uid, me.uid)    # Creates the match in the database 
    else redirect_to action: "findMatch" end
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
  end

  def destroy

  end

end
