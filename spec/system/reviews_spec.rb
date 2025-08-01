require 'rails_helper'

RSpec.describe "口コミ投稿", type: :system, js: true do
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

  it "ログインユーザーが口コミを投稿（コメント、レーティングどちらも入力）" do
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

    # 星をクリック（data-value="4" を選択）
    find(".star[data-value='4']").click
    puts "星を押して評価した"

    # hidden_fieldの値を確認
    rating_value = find("#rating-field", visible: false).value
    puts "hidden_fieldのratingの値: #{rating_value}"
    expect(rating_value).to eq "4"

    # コメントを入力
    fill_in "コメント", with: "コシが最高で出汁もうまい！"

    # 投稿ボタンをクリック
    click_button "投稿する"
    puts "口コミ投稿ボタンクリック"

    # 投稿が表示されていることを確認
    expect(page).to have_content("コシが最高で出汁もうまい！")
    expect(page).to have_css(".mb-2 .text-warning", count: 4) # /views/shared/_review_cardにあわせて

    # 表示されたコメントと評価をputsで確認
    comment_text = find("p.mb-3").text rescue "コメントが見つかりません"
    puts "表示されたコメント: #{comment_text}"

    # 星の数をカウント
    star_count = all(".mb-2 .text-warning").count
    puts "表示された星の数: #{star_count}"

    puts "投稿ボタン押下後のURL: #{current_url}"
  end
end
