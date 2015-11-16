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

  def clickLike
    puts params[:uid]
   # matched = Matching.liked()
  end
  
  

=begin
  def updateInstrument
    puts params[:instrument]
    puts params[:exp]
    params[:play] = 1
    params[:uid] = session[:user_id]
    instrument = Instrument.add(params)
    raise "foo"
  end

  def updateGenre
    puts params[:genre]
    params[:uid] = session[:user_id]
    genre = Genre.add(params)
    raise "Yaa"
  end

  def updateInfluence
    puts params[:influence]
    params[:uid] = session[:user_id]
    influence = Influence.add(params)
    raise "Taadaa"
  end

  def addMedia
    puts params[:url]
    params[:uid] = session[:user_id]
    media = Medium.add(params)
    raise "Media!!"
  end
=end

  def destroy

  end

end
