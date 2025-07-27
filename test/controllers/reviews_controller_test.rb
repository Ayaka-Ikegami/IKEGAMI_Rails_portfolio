require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # 追加

  def setup
    @user = users(:one)  # fixturesにユーザーを用意しておく
    sign_in @user       # ログイン
    @store = stores(:one) # storeのfixtureがあればセット
  end

  test "should create" do
    post reviews_url, params: { review: { store_id: @store.id, rating: 5, comment: "テストレビュー" } }
    assert_redirected_to users_profile_path
  end
end
