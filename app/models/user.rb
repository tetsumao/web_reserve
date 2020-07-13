class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :web_reservations, dependent: :destroy
  validates :email, presence: true, "valid_email_2/email": true
  validates :user_name, format: {
    with: /\A[\p{han}\p{hiragana}\p{katakana}\u{30fc}\p{alpha}\p{blank}]+\z/, allow_blank: true
  }
end
