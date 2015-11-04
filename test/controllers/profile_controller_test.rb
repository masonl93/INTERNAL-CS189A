require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  test "should get showVid" do
    get :showVid
    assert_response :success
  end

  test "should get showAud" do
    get :showAud
    assert_response :success
  end

  test "should get showSingleVid" do
    get :showSingleVid
    assert_response :success
  end

end
