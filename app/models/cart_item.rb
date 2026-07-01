class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :variant

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :variant_id, uniqueness: { scope: :cart_id }

  before_create :snapshot_price

  def price_changed?
    unit_price != variant.price
  end

  def current_price
    variant.price
  end

  def subtotal
    variant.price * quantity
  end

  private

  def snapshot_price
    self.unit_price = variant.price
  end
end
