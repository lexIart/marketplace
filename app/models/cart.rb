class Cart < ApplicationRecord
  EXPIRY_DAYS = 90

  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :variants, through: :cart_items

  before_create :set_token
  before_create :set_expiry

  def self.find_or_create_for_session(token)
    cart = find_by(token: token)
    return cart if cart&.active?

    create!(expires_at: EXPIRY_DAYS.days.from_now)
  end

  def merge_guest_cart!(guest_cart)
    return if guest_cart.nil? || guest_cart == self

    guest_cart.cart_items.each do |item|
      existing = cart_items.find_by(variant_id: item.variant_id)
      if existing
        existing.increment!(:quantity, item.quantity)
      else
        item.update!(cart: self)
      end
    end

    guest_cart.destroy
  end

  def total
    cart_items.sum { |item| item.variant.price * item.quantity }
  end

  def item_count
    cart_items.sum(:quantity)
  end

  def touch_expiry!
    update_columns(expires_at: EXPIRY_DAYS.days.from_now)
  end

  def active?
    expires_at > Time.current
  end

  private

  def set_token
    self.token = SecureRandom.hex(16)
  end

  def set_expiry
    self.expires_at = EXPIRY_DAYS.days.from_now
  end
end
