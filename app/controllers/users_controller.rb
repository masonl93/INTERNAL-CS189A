class UsersController < ApplicationController
  protect_from_forgery except: :showMatchMsgs

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

  def showMatches
    #FOR PRODUCTION
    @group = User.where('id = ? OR id = ? OR id = ?', 16, 17, 18)
    @users = User.where('id != ?', current_user.id)

    #FOR JUST THE DEMOOO
    # if current_user.name == "Ringo Starr"
    #   @users = User.where('name = ?', "John Lennon")
    # elsif current_user.name == "John Lennon"
    #   @users = User.where('name = ?', "Ringo Starr")
    # else
    #   @users = User.where('id != ?', current_user.id)
    # end

    #Chat.delete_all
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
    @groupUsers = User.find(groupdIdArray)
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

  def destroy

  end

  private

  def chat_params
    params.require(:chat).permit(:body, :match_id)
  end

  def group_chat_params
    params.require(:groupChat).permit(:body, :participants)
  end

end


