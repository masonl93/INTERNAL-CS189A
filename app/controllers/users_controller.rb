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
  end

  def update
  end

  def updateSurvey
    params[:play] = 1
    params[:uid] = session[:user_id]
    instrument = Instrument.add(params)
    genre = Genre.add(params)
    influence = Influence.add(params)
    media = Medium.add(params)
    User.update_bio(session[:user_id], params[:bio])
    redirect_to action: "show", id: session[:user_id]
  end

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

  def destroy

  end

end
