class HomeController < ApplicationController
  before_action :set_auth

  def home
    @users = User.all
  end

  def index
    @users = User.all
  end

  def profile
  end

  private

  def set_auth
    @auth = session[:omniauth] if session[:omniauth]
  end
end
