require 'rails_helper'

RSpec.describe "レビュー投稿", type: :system, js: true do
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

  it "ログインユーザーが口コミを投稿" do
    user = User.create!(user_name: "テストうどん", email: "test@example.com", password: "password")
    store = Store.create!(name: "スタブ店舗", address: "うどん県", place_id: "test_place_id")
    # ログインする
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"
    puts "ログイン完了"

    # 店舗ページへ移動
    visit store_path(store.place_id)
    puts "店舗ページへ移動"

    # 星をクリック（data-value="4" を選択）
    find(".star[data-value='4']").click
    puts "星を押して評価した"

    expect(find("#rating-field", visible: false).value).to eq "4" # レーティングフォームは非表示だがテストで探してOK

    # コメントを入力
    fill_in "コメント", with: "コシが最高で出汁もうまい！"

    # 投稿ボタンをクリック
    click_button "投稿する"
    puts "口コミ投稿ボタンクリック"

    # 投稿が表示されていることを確認
    expect(page).to have_content("コシが最高で出汁もうまい！")
    expect(page).to have_css(".mb-2 .text-warning", count: 4) # /views/shared/_review_cardに合わせて記述
  end
end
