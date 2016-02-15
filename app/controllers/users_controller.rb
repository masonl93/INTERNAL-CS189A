class UsersController < ApplicationController
  protect_from_forgery except: [:showMatchMsgs, :save_user_location]

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
    @user = User.find(session[:user_id])
    @instruments = InstrumentChoice.all       # todo: add all instrument choices to this database
                                              # then have for loop creating checkboxes in _form.html.erb
  end


  def edit2
    @user = User.find(session[:user_id])
    @user_instruments = [false, false, false, false, false]
    @user_looking = [false, false, false, false, false]
    @user.instruments.each do |i|
      if i.play == true
        if i.instrument == 'Guitar'
          @user_instruments[0] = true
        elsif i.instrument == 'Bass'
          @user_instruments[1] = true
        elsif i.instrument == 'Vocals'
          @user_instruments[2] = true
        elsif i.instrument == 'Drums'
          @user_instruments[3] = true
        elsif i.instrument == 'Keyboard'
          @user_instruments[4] = true
        end
      elsif i.play == false   # User does not play but is searching for this instrument
        if i.instrument == 'Guitar'
          @user_looking[0] = true
        elsif i.instrument == 'Bass'
          @user_looking[1] = true
        elsif i.instrument == 'Vocals'
          @user_looking[2] = true
        elsif i.instrument == 'Drums'
          @user_looking[3] = true
        elsif i.instrument == 'Keyboard'
          @user_looking[4] = true
        end
      end
    end
  end

  def update
  end

  def updateSurvey
    puts params
    params[:play] = 1
    params[:uid] = session[:user_id]
    # loop through all checkboxes checked for instruments user plays
    # creates entry in Instrument database with plays=1
    params[:instrument].each do |i|
      Instrument.add(i, 1, 1, params[:uid])   # todo: replace paramas with real values for experience and plays
    end
    # loop through all checkboxes checked for instruments user is looking for
    # creates entry in Instrument database with plays=0
    params[:looking].each do |l|
      Instrument.add(l, 1, 0, params[:uid])
    end
    # creating genre entry for each genre checked
    params[:genre].each do |g|
      Genre.add(g, params[:uid])
    end
    influences = params[:influence].split(',')
    influences.each do |i|
      Influence.add(i, params[:uid])
    end
    if params[:url] != ''
      if params[:url].include? "youtube"
        media = Medium.add(params, 'youtube')
      elsif params[:url].include? "soundcloud"
        media = Medium.add(params, 'soundcloud')
      end
    end
    User.update_bio(session[:user_id], params[:bio])
    User.update_interest_level(session[:user_id], params[:interest_level])
    User.update_radius(session[:user_id], params[:radius])
    redirect_to action: "show", id: session[:user_id]
  end

  def editSurvey
    puts params
    params[:uid] = session[:user_id]
    uid = session[:user_id]
    user = User.find(session[:user_id])
    Instrument.delete_all(uid)
    params[:instrument].each do |i|
      Instrument.add(i, 1, 1, uid)   # todo: replace paramas with real values for experience and plays
    end
    params[:looking].each do |l|
      Instrument.add(l, 1, 0, uid)
    end
    Genre.delete_all(uid)
    params[:genre].each do |g|
      Genre.add(g, uid)
    end
    influences = params[:influence].split(',')
    influences.each do |i|
      Influence.add(i, params[:uid])
    end
    User.update_bio(uid, params[:bio])
    User.update_interest_level(uid, params[:interest_level])
    User.update_radius(uid, params[:radius])
    Medium.delete_all(uid)
    Medium.add(params)

    if params[:url] != ''
      if params[:url].include? "youtube"
        media = Medium.add(params, 'youtube')
      elsif params[:url].include? "soundcloud"
        media = Medium.add(params, 'soundcloud')
      end
    end

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
    redirect_to action: "testFindMatch"
  end

  def testFindMatch
    allU = User.all
    closeU = [], elligibleU = []
    myLookingForInstruments = [], myInstruments = [],  myGenres = []
    sorted = Hash.new

    #GET INSTRUMENTS CURRENT USER WANTS AND PLAYS
    current_user.instruments.each do |inst|
      if !inst.play
        myLookingForInstruments.append(inst.instrument)
      else
        myInstruments.append(inst.instrument)
      end
    end

    #GET GENRES CURRENT USER PLAYS
    current_user.genres.each do |g|
      myGenres.append(g.genre)
    end

    #START GETTING POINTS
    allU.each do |user|
      score = 0
      userPlays = user.instruments.where("play = ?", true)
      userWants = user.instruments.where("play = ?", false)
      userGenre = user.genres

      # 1. get points for instruments and experience
      score += Matching.getInstrumentAndExperiencePoints(myLookingForInstruments, userPlays, myInstruments, userWants)

      # 2. if score = 0, then not matchable, because no instruments match. if != 0, then proceed to get other points
      if score != 0
        # 3. get genre points
        score += Matching.getGenrePoints(myGenres, userGenre)

        # FINALLY add user and score to hash.
        sorted[user.id.to_s] = score
      end
    end

    @users = sorted.sort_by { |user, score| score}.reverse!
  end


  # todo: notify user that a match occured and ask
  # if they want to continue looking for users or
  # begin a message
  # Return True if user wants to begin messaging
  # false otherwise
  def notify_user_match

  end

  # Begin a message with someone matched
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
      redirect_to action: "view_matches" and return   # this is here until we have messaging
                                                      # This just forwards a user to view their matches
                                                      # after new match occurs
      start_message = notify_user_match
      if start_message
        redirect_to action: "init_message" and return
      else
        redirect_to action: "findMatch" and return
      end
    end
    redirect_to action: "findMatch" and return
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

  def showMsgList
    @singleids = Set.new
    @groupids = Set.new

    singleChat = Chat.where('user_id = ? OR match_id = ?', current_user.id, current_user.id)
    singleChat.each do |chat|
      if chat.user_id == current_user.id
        @singleids.add(chat.match_id)
      else
        @singleids.add(chat.user_id)
      end
    end

    groupChat = Group.all
    groupChat.each do |chat|
      ids = chat.participants.split(",").map(&:to_i)
      if ids.include? current_user.id
        @groupids.add(ids)
      end

    end

  end

  def showMatches
    #FOR PRODUCTION
    #@group = User.where('id = ? OR id = ? OR id = ? OR id = ?', 16, 17, 18, 19).order(:id)
    @users = User.where('id != ?', current_user.id)


  end

  def showMatchMsgs
    @chat = Chat.new
    @match = User.find(params[:id])
    me = User.find(session[:user_id])       #WARNING: Unused variable 'me'

    mychat = Chat.order('created_at DESC').where(:user_id => current_user.id).where(:match_id => @match.id)
    matchchat = Chat.order('created_at DESC').where(:user_id => @match.id).where(:match_id => current_user.id)
    @chats = (mychat + matchchat).sort_by { |chat| chat[:id] }.reverse!

    #render :template => 'users/showMatchMsgs.js.erb'
    #@chats = Chat.order('created_at DESC').where(:user_id => @match.id).where(:match_id => current_user.id)
      #@chats = Chat.all
    #@chats = current_user.chats.where()
  end

  def showGroupMsgs
    @groupChat = Group.new
    @groupid = params[:ids]
    groupdIdArray = @groupid.split(",")
    @groupUsers = User.find(groupdIdArray).sort_by { |user| user[:id]}

    @chats = Group.where(:participants => @groupid).order(:id).reverse_order
  end

  def createChat
    respond_to do |format|
      if current_user
        @chats = current_user.chats.build(chat_params)
        if @chats.save
          #flash[:success] = 'Your message was sent!'
          format.html {redirect_to action: "showMatchMsgs", id:params[:id]}
          format.js
        else
          flash[:error] = 'Your message not sent :('
        end
        #redirect_to action: "showMatchMsgs", id:params[:id]


      else
        format.html {redirect_to root_url}
        format.js {render nothing: true}
      end
    end
  end

  def createGroupChat
    respond_to do |format|
      if current_user
        @groupChats = current_user.groups.build(group_chat_params)
        if @groupChats.save
          #flash[:success] = 'Your message was sent!'
          format.html {redirect_to action: "showGroupMsgs", id:params[:ids]}
          format.js
        else
          flash[:error] = 'Your message not sent :('
        end
        #redirect_to action: "showMatchMsgs", id:params[:id]


      else
        format.html {redirect_to root_url}
        format.js {render nothing: true}
      end
    end
  end

  def save_user_location
   current_user.update_attributes!(user_location_params)
   head :ok
  end

  def destroy

  end

  private

  def chat_params
    params.require(:chat).permit(:body, :match_id)
  end

  def group_chat_params
    params.require(:group).permit(:body, :participants)
  end

  def user_location_params
    params.permit(:lat,:long)
  end

end
