# --- ユーザー ---
user1 = User.find_or_create_by!(email: "sample1@example.com") do |user|
  user.password = "password"
  user.user_name = "流浪のうどん大好き人間"
end

user2 = User.find_or_create_by!(email: "sample2@example.com") do |user|
  user.password = "password"
  user.user_name = "サヌさぬき"
end

# --- テスト用の店舗（Google Mapを使わずに仮店舗） ---
store1 = Store.find_or_create_by!(place_id: "test-place-001") do |store|
  store.name = "テストうどん本舗"
  store.address = "東京都渋谷区1-2-3"
end

store2 = Store.find_or_create_by!(place_id: "test-place-002") do |store|
  store.name = "テストかがわうどん研究所"
  store.address = "香川県高松市番町2-2-2"
end

# --- 口コミ ---
Review.find_or_create_by!(user: user1, store: store1) do |review|
  review.rating = 5
  review.comment = "麺のコシが絶妙！！！最高！！！"
end

Review.find_or_create_by!(user: user2, store: store2) do |review|
  review.rating = 5
  review.comment = "麺も出汁もおいしくて毎日食べてます！"
end

Review.find_or_create_by!(user: user1, store: store2) do |review|
  review.rating = 5
  review.comment = "スルスル飲めるタイプの細めうどんは夏にピッタリ！"
end
