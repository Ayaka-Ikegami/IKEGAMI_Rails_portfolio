require 'rails_helper'

RSpec.describe "口コミ投稿のバリデーション", type: :system, js: true do
  before { puts "テスト開始" }
  after  { puts "テスト終了" }

  before do
    driven_by(:selenium_chrome_headless)

    # Google APIのスタブ
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

  it "レーティングが未選択だとバリデーションエラーになり、口コミは投稿されない" do
    user = User.create!(user_name: "テストうどん", email: "test@example.com", password: "password")
    store = Store.create!(name: "スタブ店舗", address: "うどん県", place_id: "test_place_id")
    # ログインする
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    puts "ログインページのURL: #{current_url}"
    click_button "ログイン"
    puts "ログイン完了"

    # 口コミページへ移動
    visit new_review_path(store_id: store.id)
    puts "口コミページへ移動"
    puts "口コミページのURL: #{current_url}"

    # レーティングは選択しない！星はノットクリック！

    # コメントを入力
    fill_in "コメント", with: "レーティング未選択！コシのあるうどん"
    puts "コメント入力"

    # 投稿ボタンをクリック
    click_button "投稿する"
    puts "口コミ投稿ボタンクリック"

    # バリデーションにより、投稿が失敗したことを確認
    expect(page).to have_current_path(new_review_path, ignore_query: true) # POST先でrender :new想定
    expect(page).to have_content("口コミを投稿できませんでした。") # flash.now[:alert] の確認
    expect(page).to have_selector("form") # フォームが再表示されているか？

    puts "投稿ボタン押下後のURL: #{current_url}"
  end
end
