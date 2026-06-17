class Product < ApplicationRecord
  # FK - seller_id in user.rb model
  belongs_to :seller, class_name: 'User'
  # FK - category_id in category.rb model
  belongs_to :category, optional: true

  has_many :variants, dependent: :destroy
  has_many :product_option_types, dependent: :destroy
  has_many :option_types, through: :product_option_types
  # has_many :product_images, dependent: :destroy

  accepts_nested_attributes_for :variants, allow_destroy: true

  # ActiveStorage - active_storage_attachments + active_storage_blobs
  # record.id = product.id?
  has_one_attached :thumbnail # main pic
  # has_many_attached :images # gallery -> later

  # action_text_rich_texts
  has_rich_text :description # Action Text

  enum :status, {
    draft: 0,
    published: 1,
    archived: 2
  }, suffix: true # published?, draft? и т.д. + scope published

  scope :published, lambda {
    where(status: :published)
      .where('published_at IS NULL OR published_at <= ?', Time.current)
  }

  scope :by_seller, ->(seller) { where(seller: seller) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  # alias instead of Product.published
  scope :visible, -> { published }

  validates :name, presence: true,
                   length: { maximum: 255 }

  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  validates :status, presence: true
  validates :seller, presence: true

  before_validation :generate_slug, if: -> { slug.blank? || name_changed? }

  def to_param
    slug
  end

  # api
  def publish!
    update(status: :published, published_at: Time.current)
  end

  # api
  def unpublish!
    update(status: :draft, published_at: nil)
  end

  private

  def generate_slug
    return if name.blank?

    self.slug = name.parameterize(locale: :ru)
                    .presence || name.smart_parameterize
  end
end
