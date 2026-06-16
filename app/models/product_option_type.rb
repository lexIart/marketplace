class ProductOptionType < ApplicationRecord
  belongs_to :product
  belongs_to :option_type
end
