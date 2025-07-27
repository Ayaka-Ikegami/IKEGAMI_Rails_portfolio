require 'rails_helper'

RSpec.describe "レビュー投稿のバリデーション", type: :system, js: true do
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

  it "コメントが空欄だとバリデーションエラーになり、口コミは投稿されない" do
    user = User.create!(user_name: "バリデーションうどん", email: "valudon@example.com", password: "password")
    store = Store.create!(name: "スタブ店舗", address: "うどん県", place_id: "test_place_id")

    # ログイン
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"
    puts "ログイン完了"

    # 店舗ページへ
    visit store_path(store.place_id)

    # 星だけ押す（コメントは空）
    find(".star[data-value='3']").click
    fill_in "コメント", with: ""
    puts "星を押して評価した"

    # 投稿
    click_button "投稿する"
    puts "コメント抜きで投稿ボタンクリック"

    # エラーメッセージ表示
    expect(page).to have_content("コメントを入力してください")
    expect(page).not_to have_content("口コミを投稿できませんでした。") # 成功メッセージがでないように！
  end
end
