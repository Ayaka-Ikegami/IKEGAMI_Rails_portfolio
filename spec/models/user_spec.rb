require 'rails_helper'

RSpec.describe User, type: :model do
  it "有効なユーザーアカウント：バリデーションクリア" do
    user = User.new(user_name: "テストユーザー", email: "test@example.com", password: "password")
    expect(user).to be_valid
  end

  it "名前がないと無効になる" do
    user = User.new(user_name: nil, email: "test@example.com", password: "password")
    expect(user).not_to be_valid
  end

  it "メールアドレスがないと無効になる" do
    user = User.new(user_name: "テストユーザー", email: nil, password: "password")
    expect(user).not_to be_valid
  end

  it "パスワードがないと無効になる" do
    user = User.new(user_name: "テストユーザー", email: "test@example.com", password: nil)
    expect(user).not_to be_valid
  end

  describe "複数レビュークリア" do
    it "ユーザーに紐づいた複数のレビューがあること" do
      store = Store.create!(
        name: "テストうどん店舗",
        address: "東京都渋谷区1-1-1",
        place_id: SecureRandom.uuid
      )
      user = User.create!(user_name: "テストユーザー", email: "test@example.com", password: "password")
      review1 = Review.create(user: user, store: store, comment: "テストレビュー1", rating: 4)
      review2 = Review.create(user: user, store: store, comment: "テストレビュー2", rating: 4)

      expect(user.reviews).to include(review1, review2)
    end
  end

  describe "ユーザー削除時に関連するレビューも削除される" do
    it "レビューも一緒に削除される" do
      store = Store.create!(
        name: "テスト店舗",
        address: "東京都渋谷区1-1-1",
        place_id: SecureRandom.uuid
      )
      user = User.create!(user_name: "テストユーザー", email: "test@example.com", password: "password")
      Review.create!(user: user, store: store, comment: "テストレビュー", rating: 5)

      expect { user.destroy }.to change { Review.count }.by(-1)
    end
  end

  it "PNG画像が許可されている" do
    user = User.new(user_name: "テストユーザー", email: "test@example.com", password: "password")
    user.avatar.attach(io: File.open(Rails.root.join("spec/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    expect(user).to be_valid
  end

  it "不正なファイル形式だと無効になる" do
    user = User.new(user_name: "テストユーザー", email: "test@example.com", password: "password")
    user.avatar.attach(io: File.open(Rails.root.join("spec/fixtures/files/sample.svg")), filename: "sample.svg", content_type: "image/svg")
    expect(user).not_to be_valid
    expect(user.errors[:avatar]).to include("はPNG・JPG・JPEG形式のみアップロード可能です")
  end

  describe ".guest" do
    it "ゲストユーザーを新規作成する（初回）" do
      user = User.guest
      expect(user).to be_persisted
      expect(user.email).to eq("guest@example.com")
      expect(user.user_name).to eq("ゲスト")
    end

    it "2回目以降は同じゲストユーザーを返す" do
      first_user = User.guest
      second_user = User.guest
      expect(second_user.id).to eq(first_user.id)
    end

    it "ゲストユーザーにはパスワードが設定されている" do
      user = User.guest
      expect(user.encrypted_password).not_to be_blank
    end
  end
end
