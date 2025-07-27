require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'バリデーション' do
    before do
      @user = User.create!(
        user_name: "テストユーザー",
        email: "test@example.com",
        password: "password"
      )
      @store = Store.create!(
        name: "テストうどん店",
        address: "東京都港区1-1-1",
        place_id: "test_place_001"
      )
    end

    it '有効なレビューである' do
      review = Review.new(user: @user, store: @store, rating: 4, comment: "コメントあり")
      expect(review).to be_valid
    end

    it 'レーティング（評価）がないと無効になる' do
      review = Review.new(user: @user, store: @store, comment: "コメントのみ")
      expect(review).not_to be_valid
    end

    it 'コメントがないと無効になる' do
      review = Review.new(user: @user, store: @store, rating: 3)
      expect(review).not_to be_valid
    end

    it 'コメントが1000文字以内である' do
      not_over_comment = "う" * 1000
      review = Review.new(user: @user, store: @store, rating: 3, comment: not_over_comment)
      expect(review).to be_valid
    end

    it 'コメントが1001文字以上だと無効になる' do
      over_comment = "ど" * 1001
      review = Review.new(user: @user, store: @store, rating: 3, comment: over_comment)
      expect(review).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'storeとreviewは一対多の関係' do
      assoc = described_class.reflect_on_association(:store)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'userとreviewは一対多の関係' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end
