class Variant < ApplicationRecord
  belongs_to :product

  has_many :variant_option_values, dependent: :destroy
  has_many :option_values, through: :variant_option_values
  has_many :option_types, -> { distinct }, through: :option_values

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: 'active') }
  scope :in_stock, -> { where('stock > 0') }

  def option_summary
    option_values
      .joins(:option_type)
      .order('option_types.position, option_values.position')
      .map(&:presentation)
      .join(' / ')
  end

  def to_s
    "#{product.name} — #{option_summary}"
  end
end
