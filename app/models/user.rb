class User < ApplicationRecord
  
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable

  validates :user_name, presence: true
  validates :email, presence: true
  validates :password, presence: true, confirmation: true, on: :create

  def self.guest
    find_or_create_by!(email: "guest@example.com") do |user|
      user.password = SecureRandom.urlsafe_base64
    end
  end
end
