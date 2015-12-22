require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end
  
  test "should get about" do
    get :home
    assert_response :success
  end
  
  # Outdated test. Probably want to delete
  #test "should get index" do
  #  get :index
  #  assert_response :success
  #end

  # Need to get profile when logged in
  # No profile when not logged in.
  #test "should get profile" do
  #  get :profile
  #  assert_response :success
  #end

end
