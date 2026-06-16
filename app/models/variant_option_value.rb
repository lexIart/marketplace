class VariantOptionValue < ApplicationRecord
  belongs_to :variant
  belongs_to :option_value

  # Дополнительная защита от дублирования
  validates :variant_id, uniqueness: { scope: :option_value_id }
end
