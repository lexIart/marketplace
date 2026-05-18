class Category < ApplicationRecord
  # Assoications
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category',
                           foreign_key: :parent_id,
                           dependent: :destroy,
                           inverse_of: :parent

  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :roots, -> { where(parent_id: nill).order(:position) }
  scope :ordered, -> { order(:position) }
  scope :with_depth, ->(depth) { where('parent_id IS NULL') if depth == 0 }

  # Callbacks
  before_validation :generate_slug, if: :name_changed?

  # Instance
  def root?
    parent_id.nil?
  end

  def depth
    parent ? parent.depth + 1 : 0
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
