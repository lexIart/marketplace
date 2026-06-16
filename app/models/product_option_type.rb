class ProductOptionType < ApplicationRecord
  belongs_to :product
  belongs_to :option_type

  validates :option_type_id, uniqueness: { scope: :product_id }

  # Для сортировки опций на фронте
  validates :position, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
