class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :confirmable,
         :validatable

  enum :role, { buyer: 'buyer', seller: 'seller', admin: 'admin' },
       # role-assoicated methods generate (role_seller? and etc.)
       suffix: true,
       default: :buyer

  # Assoications

  has_many :products, dependent: :destroy

  has_many :orders_as_buyer,
           class_name: 'Order',
           foreign_key: :buyer_id,
           dependent: :nullify,
           inverse_of: :buyer

  has_many :orders_as_seller,
           through: :products,
           source: :orders

  has_many :reviews,
           foreign_key: :reviewer_id,
           dependent: :destroy

  # ActiveStorage
  has_one_attached :avatar

  validates :first_name,
            :last_name,
            presence: true,
            length: { maximum: 100 }

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-z0-9_]+\z/ }

  before_validation :downcase_username, if: :username_changed?

  def full_name
    "#{first_name} #{last_name}".strip.presence || "@#{username}"
  end

  def display_name
    "@#{username}"
  end

  # sugar + 'thin abstraction'
  def seller?
    role_seller?
  end

  def admin?
    role_admin?
  end

  private

  def downcase_username
    self.username = username.to_s.downcase.strip if username.present?
  end
end
