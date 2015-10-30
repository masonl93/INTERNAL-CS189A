class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    auth = request.env["omniauth.auth"]
    session[:omniauth] = auth.except('extra')
    user = User.sign_in_from_omniauth(auth)
    puts user
    session[:user_id] = user.id
    #redirect_to root_url, notice: "SIGNED IN"
    #redirect_to root_url
    redirect_to action: :edit, id: session[:user_id]
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path
    else
      redirect_to action: :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to users_path
    else
      render :action => :edit
    end
  end

  def destroy
    @user = User.find(user_params)
    @user.destroy
    redirect_to users_path
  end

  def end_session
    session[:user_id] = nil
    session[:omniauth] = nil
    puts 'hey'
    redirect_to 'users_path'
  end

  def show
    @user = User.find(params[:user_id])
  end


  private

  def user_params
    #params.require(:user).permit(:name, :email, :instruments, :looking_for, :guitar, :drum, :bass, :sing)
    params.require(:user).permit(:guitar, :drum, :bass, :sing)
  end


end