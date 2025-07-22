require "test_helper"

class Users::ProfileControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:one)  # fixturesのユーザーを利用する例
    sign_in @user
  end

  test "should get show" do
    get users_profile_path
    assert_response :success
  end
end
