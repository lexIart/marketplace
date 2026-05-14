class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :confirmable,
         :validatable

  enum :role, {
    buyer: 'buyer',
    seller: 'seller',
    admin: 'admin'
  }, suffix: true, default: :buyer

  has_many :products, foreign_key: :seller_id, dependent: :destroy
  has_many :orders,   foreign_key: :buyer_id,  dependent: :destroy
  has_many :reviews,  foreign_key: :reviewer_id, dependent: :destroy

  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
end
