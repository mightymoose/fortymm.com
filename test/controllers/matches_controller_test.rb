require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get match_url(matches(:one))
    assert_response :success
  end
end
