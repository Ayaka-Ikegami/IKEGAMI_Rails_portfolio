class User < ApplicationRecord
  has_many :reviews, dependent: :destroy

  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable

  validates :user_name, presence: true, length: { maximum: 15 }
  validates :email, presence: true
  validates :password, presence: true, confirmation: true, on: :create

  has_one_attached :avatar
  validate :avatar_format

def self.guest
  find_or_create_by!(email: "guest@example.com") do |user|
    user.password = SecureRandom.urlsafe_base64
    user.name = "ゲスト"
  end.tap do |user|
    user.update(user_name: "ゲスト") if user.user_name.blank?
  end
end

private

  def avatar_format
    return unless avatar.attached?
    if !avatar.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add(:avatar, "はPNG・JPG・JPEG形式のみアップロード可能です")
    end
  end
end
