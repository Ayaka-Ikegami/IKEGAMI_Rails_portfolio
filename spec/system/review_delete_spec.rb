require 'rails_helper'

RSpec.describe "口コミ削除", type: :system do
  before { puts "テスト開始" }
  after  { puts "テスト終了" }

  before do
    driven_by(:rack_test)

    stub_request(:get, /maps.googleapis.com/).to_return(
      body: {
        status: "OK",
        result: {
          name: "スタブ店舗",
          formatted_address: "うどん県"
        }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  it "自分の口コミを削除できる" do
    user = User.create!(user_name: "うどん削除さん", email: "deleter@example.com", password: "password")
    store = Store.create!(name: "削除対象うどん店", address: "うどん県", place_id: "delete_place")
    review = Review.create!(user:, store:, rating: 3, comment: "消されるうどん")

    # ログイン
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"
    expect(page).to have_current_path(root_path).or have_current_path("/") # ログイン後トップページ遷移
    puts "ログインしました"

    # プロフィールページに移動
    visit users_profile_path
    expect(page).to have_content("消されるうどん")
    puts "プロフィールページのURL: #{current_url}"

    expect {
      click_button "削除"
    }.to change { Review.count }.by(-1)

    expect(page).to have_current_path(/\/users\/profile/, ignore_query: true)
    expect(page).not_to have_content("消されるうどん")
    puts "削除成功しました"
    puts "プロフィールページ（口コミ削除後）のURL: #{current_url}"
  end
end
