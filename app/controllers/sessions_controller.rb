class SessionsController < ApplicationController


  def create
    auth = request.env["omniauth.auth"]
    puts auth
    session[:omniauth] = auth.except('extra')
    if User.where(:uid => auth['uid']).first() != nil
      session[:user_id] = User.where(:uid => auth['uid']).first()[:id]
      redirect_to "/matching", id: session[:user_id]
    else
      user = User.sign_in_from_omniauth(auth)
      session[:user_id] = user.id
      redirect_to "/edit", id: user.id
    end
  end


  # Uncomment this create function and comment out the other create function
  # when testing survey since this function redirects to survey on each login

  # def create
  #   auth = request.env["omniauth.auth"]
  #   puts auth
  #   session[:omniauth] = auth.except('extra')
  #   user = User.sign_in_from_omniauth(auth)
  #   session[:user_id] = user.id
  #   redirect_to "/edit", id: user.id
  # end


  def destroy
    session[:user_id] = nil
    session[:omniauth] = nil
    redirect_to root_url, notice: "SIGNED OUT"
  end
end
