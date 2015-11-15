require 'test_helper'

class MatchingControllerTest < ActionController::TestCase
  test "should get match" do
    get :match
    assert_response :success
  end

end
