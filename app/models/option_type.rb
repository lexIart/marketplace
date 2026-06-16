class OptionType < ApplicationRecord
  # Ассоциации
  has_many :option_values, -> { order(:position) }, dependent: :destroy
  has_many :product_option_types, dependent: :destroy
  has_many :products, through: :product_option_types

  # Валидации
  validates :name, presence: true, uniqueness: true
  validates :presentation, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def to_s
    presentation
  end
end
