require 'rails_helper'

RSpec.describe "口コミ投稿ページにアクセスできない！", type: :system, js: true do
  before { puts "テスト開始" }
  after  { puts "テスト終了" }

  before do
    driven_by(:selenium_chrome_headless)

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

  it "「非」ログインユーザーは口コミページにアクセスできない" do
    store = Store.create!(name: "スタブ店舗", address: "うどん県", place_id: "test_place_id")

    # ログインしない！！

    # 口コミページへ移動
    visit new_review_path(store_id: store.id)
    puts "口コミページへ移動したかったが・・・できない"

    # ログインページにリダイレクトされることを確認
    expect(page).to have_current_path(new_user_session_path)
    puts "リダイレクト後のURL: #{current_url}"
  end
end
