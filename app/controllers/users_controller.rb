require 'json'
require 'open-uri'

class UsersController < ApplicationController
  protect_from_forgery except: [:showMatchMsgs, :save_user_location]
  skip_before_filter :verify_authenticity_token

  @neo = Neography::Rest.new("http://neo4j:arbor94@localhost.com:7474")

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
    #@instruments = InstrumentChoice.all       # todo: add all instrument choices to this database
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
      genres = get_genre_from_influence(i)
      Influence.add(i, params[:uid], genres)
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
      Instrument.add(i, 1, 1, uid)   # todo: replace params with real values for experience and plays
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
      genres = get_genre_from_influence(i)
      Influence.add(i, params[:uid], genres)
    end
    User.update_bio(uid, params[:bio])
    User.update_interest_level(uid, params[:interest_level])
    User.update_radius(uid, params[:radius])
    Medium.delete_all(uid)

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


    allU = User.all.where("id != ?", current_user.id)
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
    allU.each do |user|
      if Matching.ifElligible(current_user.id.to_s, user)
        elligibleU.append(user)
      end
    end

    #START GETTING POINTS
    elligibleU.each do |user|
      score = 0
      #  FIRST CHECK TO SEE IF MATCH IS USER'S RADIUS
      #if User.getDistance([current_user.lat, current_user.long], [user.lat, user.long]) <= current_user.radius
        userPlays = user.instruments.where("play = ?", true)
        userWants = user.instruments.where("play = ?", false)
        userGenre = user.genres

        # 1. get points for instruments and experience
        score += Matching.getInstrumentAndExperiencePoints(myLookingForInstruments, userPlays, myInstruments, userWants)

        # 2. if score = 0, then not matchable, because no instruments match. if != 0, then proceed to get other points
        if score != 0
          # 3. get genre points
          score += Matching.getGenrePoints(myGenres, userGenre)

          # 4. get influence points
          score += Matching.getInfluencePoints(current_user.influences, user.influences)
          # 5. get profile likes points

          # FINALLY add user and score to hash.
          sorted[user.id.to_s] = score
        end
      #end

    end

    users = sorted.sort_by { |user, score| score}
    if users.size() == 0
      render :no_new_users
    else
      users.each do |id, score|
        @user = User.find(id.to_i)
      end
    end


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
      #  FIRST CHECK TO SEE IF MATCH IS USER'S RADIUS
      if User.getDistance([current_user.lat, current_user.long], [user.lat, user.long]) <= current_user.radius
        userPlays = user.instruments.where("play = ?", true)
        userWants = user.instruments.where("play = ?", false)
        userGenre = user.genres

        # 1. get points for instruments and experience
        score += Matching.getInstrumentAndExperiencePoints(myLookingForInstruments, userPlays, myInstruments, userWants)

        # 2. if score = 0, then not matchable, because no instruments match. if != 0, then proceed to get other points
        if score != 0
          # 3. get genre points
          score += Matching.getGenrePoints(myGenres, userGenre)

          # 4. get influence points
          score += Matching.getInfluencePoints(current_user.influences, user.influences)
          # 5. get profile likes points

          # FINALLY add user and score to hash.
          sorted[user.id.to_s] = score
        end
      end

    end

    users = sorted.sort_by { |user, score| score}.reverse!
    @users = users
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
    userID = params[:id].to_s
    meID = current_user.id.to_s


    # Find the correct match between the two users
    if Matching.where(user1: meID, user2: userID).exists?
      the_match = Matching.where(user1: meID, user2: userID).first!
    elsif Matching.where(user1: userID, user2: meID).exists?
      the_match = Matching.where(user1: userID, user2: meID).first!
    end


    # Checking if the like button or dislike button was pressed
    # in order to properly update status value
    if params.has_key?(:like)
      if !Matching.matchExists(meID, userID)
        Matching.createMatch(meID, userID, 1)
        the_match = Matching.where(user1: meID, user2: userID).first!
      else
        the_match = Matching.updateLikeStatus(the_match, meID, userID)
      end
    elsif params.has_key?(:dislike)
      if !Matching.matchExists(meID, userID)
        Matching.createMatch(meID, userID, -1)
        the_match = Matching.where(user1: meID, user2: userID).first!
      else
        the_match = Matching.updateDislikeStatus(the_match, meID, userID)
      end
    end

    # Check to see if we have a match
    if the_match.status == 3
      flash[:notice] = "You have a new match with " + User.find(params[:id]).name + "!"
    end
    redirect_to action: "findMatch" and return
  end


  def view_matches
    me = User.find(session[:user_id])
    #@matches = Matching.where("(user1 = ? OR user2 = ?) AND status = ?", me.uid, me.uid, 2)
    @matches = Matching.where('user1 = ? OR user2 = ?', me.uid, me.uid)
    @matched_users = []
    @statuses = []
    @matches.each do |match|
      if match.user1 == me.uid
        user = User.where(:uid => match.user2).first()
      else
        user = User.where(:uid => match.user1).first()
      end
        status = match.status
      @matched_users << user
      @statuses << status
    end
  end

  def showMsgList
    @singleids = Array.new
    @groupids = Set.new
    @allids = Array.new
    singleChat = Chat.where('user_id = ? OR match_id = ?', current_user.id, current_user.id)
    singleChat.each do |chat|
      if chat.user_id == current_user.id
        @singleids.delete_if {|id| id == chat.match_id }
        @singleids.unshift(chat.match_id)
      else
        @singleids.delete_if {|id| id == chat.user_id }
        @singleids.unshift(chat.user_id)
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

    #@users = User.where('id != ?', current_user.id)
    matchesID = Matching.getAllMatches(current_user.id.to_s)
    if matchesID.length == 0
      render :no_matches
    else
      @users = User.find(matchesID)
    end


  end

  def get_local_events
    @user = User.find(session[:user_id])
    @events_title = []
    @events_descript = []
    @events_url = []
    @events_time = []
    @events_month = []
    @events_date = []
    @events_venue = []

    eventful_key = "NVkK26nn5QQPffwS"
    eventful_url = "http://api.eventful.com/json/events/search?app_key=" + eventful_key + "&location=" + (@user.lat).to_s + ',' + (@user.long).to_s + "&within=50&sort_order=date&date=Future&category=music&page_size=20&change_multi_day_start=1"
    json_obj = JSON.parse(open(eventful_url).read)
    full_sanitizer = Rails::Html::FullSanitizer.new
    @num_of_events = json_obj['page_size']
    json_obj['events']['event'].each do |e|
      @events_title << e["title"]
      if e["description"] == NIL
        @events_descript << "No description provided"
      elsif
        @events_descript << full_sanitizer.sanitize(HTMLEntities.new.decode(e["description"]))
      end
      @events_url << HTMLEntities.new.decode(e["url"])
      @events_time << e["start_time"]     # format = 2016-05-24 15:00:00
      @events_date << e["start_time"].split("-")[2][0,2]
      @events_month << get_month_name(e["start_time"].split("-")[1])
      @events_venue << e["venue_name"]
    end

    if @events_title != NIL
      @events = @events_title.zip @events_descript,@events_date,@events_month,@events_venue,@events_url,@events_time
      render "show_local_events"
    elsif
      render "no_events"
    end
  end

  def get_user_events
    @events_title = []
    @events_descript = []
    @events_url = []
    @events_time = []
    @events_month = []
    @events_date = []
    @events_venue = []

    @user_events = Event.all
    @user_events.each do |e|
      @events_title << e.title
      @events_descript << e.description
      @events_url << e.url
      @events_time << e.date.split(" ")[1]
      @events_month << get_month_name(e.date.split("-")[1])
      @events_date << e.date.split("-")[2][0,2]
      @events_venue << e.location
    end


    if @user_events != []
      @events = @events_title.zip @events_descript,@events_date,@events_month,@events_venue,@events_url,@events_time
      render "show_user_events"
    elsif
      render "no_events"
    end
  end

  def add_event

  end

  def create_event
    date_time_format = params[:date] + ' ' + params[:time]  #yyyy:mm:dd time
    link = params[:link]
    if !link.start_with? 'http'
      link = 'http://' + link
    end
    Event.add(session[:user_id], params[:title], date_time_format, params[:descript], link, params[:location])
    redirect_to action: "get_user_events"
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
        @chats = current_user.chats.build(create_chat_params)
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

  def newChat
    #params.require(:newChat).permit(:recipients, :body)
    matchid = params[:recipients].to_i
    body = params[:body]
    @chat = current_user.chats.build("match_id" => matchid, "body" => body)
    if @chat.save
      redirect_to action: "showMatchMsgs", id:matchid
    else
      flash[:error] = 'Your message not sent :('
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

  def create_chat_params
    params.require(:chat).permit(:body, :match_id)
  end

  def group_chat_params
    params.require(:group).permit(:body, :participants)
  end

  def user_location_params
    params.permit(:lat,:long)
  end

  # Function for getting genres from influences from EchoNest music api
  def get_genre_from_influence(influence)
    genres = ''
    influence = URI.encode(influence)
    echo_key = "HERVF6HKUVVUHY7EW"
    echonest_url = "http://developer.echonest.com/api/v4/artist/profile?api_key=" + echo_key + "&name=" + influence + "&bucket=genre&format=json"
    json_obj = JSON.parse(open(echonest_url).read)
    if json_obj['response']['status']['code'] == 0
      json_obj['response']['artist']['genres'].each do |genre|
        if genres == ''
          genres = genre['name']
        else
          genres = genres + ',' + genre['name']
        end
      end
    end
    return genres
  end

  def get_month_name(num)
    case num
      when '01'
        return "Jan"
      when '02'
        return "Feb"
      when '03'
        return "Mar"
      when '04'
        return "Apr"
      when '05'
        return "May"
      when '06'
        return "Jun"
      when '07'
        return "Jul"
      when '08'
        return "Aug"
      when '09'
        return "Sept"
      when '10'
        return "Oct"
      when '11'
        return "Nov"
      when '12'
        return "Dec"
      else
        return "Month"
    end
  end

end
