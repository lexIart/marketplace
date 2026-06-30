class Variant < ApplicationRecord
  belongs_to :product

  has_many :variant_option_values, dependent: :destroy
  has_many :option_values, through: :variant_option_values
  has_many :option_types, -> { distinct }, through: :option_values

  has_many_attached :images

  before_validation do
    self.sku2 = sku2.presence
    self.ean  = ean.presence
  end

  validates :sku, presence: true, uniqueness: true
  validates :sku2, uniqueness: { allow_blank: true }
  validates :ean, uniqueness: { allow_blank: true },
                  format: { with: /\A(\d{8}|\d{13})\z/, message: 'должен содержать 8 или 13 цифр', allow_blank: true }
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
