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

  it "コメントが空欄だとバリデーションエラーになり、口コミは投稿されない" do
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

    # コメントは入力しない！空欄！
    fill_in "コメント", with: ""

    # 投稿ボタンをクリック
    click_button "投稿する"
    puts "口コミ投稿ボタンクリック"

    # バリデーションにより、投稿が失敗したことを確認
    expect(page).to have_current_path(new_review_path, ignore_query: true) # POST先でrender :newされてる想定
    expect(page).to have_content("口コミを投稿できませんでした。") # flash.now[:alert] の確認
    expect(page).to have_selector("form") # フォームが再表示されているか？
    expect(page).not_to have_content("コシが最高で出汁もうまい！") # 成功メッセージや投稿が出てないことを確認

    puts "投稿ボタン押下後のURL: #{current_url}"
  end
end
