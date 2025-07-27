require 'rails_helper'

RSpec.describe Store, type: :model do
  describe "バリデーション" do
    it "有効なうどん店は保存OK" do
      store = Store.new(name: "テストうどん店舗", place_id: "place_123")
      expect(store).to be_valid
    end

    it "place_idがないと無効になる" do
      store = Store.new(name: "テストうど店舗")
      expect(store).not_to be_valid
    end

    it "nameがないと無効になる" do
      store = Store.new(place_id: "place_123")
      expect(store).not_to be_valid
    end

    it "同じplace_idは無効になる" do
      Store.create!(name: "店舗うどA", place_id: "place_123")
      duplicate = Store.new(name: "店舗うどB", place_id: "place_123")
      expect(duplicate).not_to be_valid
    end
  end

  describe "アソシエーション" do
    it "storeとreviewは一対多の関係" do
      assoc = described_class.reflect_on_association(:reviews)
      expect(assoc.macro).to eq :has_many
    end
  end
end
