class Store < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :place_id, presence: true, uniqueness: true
  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end
end
