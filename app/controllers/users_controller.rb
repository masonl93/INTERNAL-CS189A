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
      if (!Matching.matchExists(@user.uid, me.uid) && @user.uid != me.uid)
        @userMatch = Matching.createMatch(@user.uid, me.uid)    # Creates the match in the database
        return
      end
    end
    render "no_new_users"
  end

  def notify_user_match

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

  def showMatches
    @users = User.all
    #Chat.delete_all
  end

  def showMatchMsgs
    @chat = Chat.new
    @match = User.find(params[:id])
    me = User.find(session[:user_id])

    mychat = Chat.order('created_at DESC').where(:user_id => current_user.id).where(:match_id => @match.id)
    matchchat = Chat.order('created_at DESC').where(:user_id => @match.id).where(:match_id => current_user.id)
    @chats = (mychat + matchchat).sort_by { |chat| chat[:id] }.reverse!

    #@chats = Chat.order('created_at DESC').where(:user_id => @match.id).where(:match_id => current_user.id)
      #@chats = Chat.all
    #@chats = current_user.chats.where()
  end

  def createChat
    if current_user
      @chat = current_user.chats.build(chat_params)
      if @chat.save
        flash[:success] = 'Your message was sent!'
      else
        flash[:error] = 'Your message not sent :('
      end
    end
    redirect_to action: "showMatchMsgs", id:params[:id]
  end

  def destroy

  end

  private

  def chat_params
    params.require(:chat).permit(:body, :match_id)
  end

end
