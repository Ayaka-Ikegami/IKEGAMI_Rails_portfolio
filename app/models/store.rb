class Store < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :place_id, presence: true, uniqueness: true
  validates :store_name, presence: true
end
