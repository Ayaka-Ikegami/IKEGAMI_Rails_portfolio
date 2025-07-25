class Review < ApplicationRecord
  belongs_to :store
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5, message: "は星マークを選択して行ってください" }
  validates :comment, presence: true, length: { maximum: 1000 }

  def self.ransackable_associations(auth_object = nil)
    [ "store", "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "comment" ]
  end
end
