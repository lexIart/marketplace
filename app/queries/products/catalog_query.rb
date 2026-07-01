# frozen_string_literal: true

module Products
  class CatalogQuery
    SORT_OPTIONS = {
      'newest' => { published_at: :desc },
      'oldest' => { published_at: :asc },
      'name_asc' => { name: :asc },
      'name_desc' => { name: :desc }
    }.freeze

    def initialize(params = {})
      @category_slug = params[:category]
      @sort          = params[:sort]
    end

    def call
      # all published products
      scope = base_scope
      # category filtering
      scope = filter_by_category(scope)
      apply_sort(scope)
    end

    private

    def base_scope
      Product.published.includes(:category, :variants, thumbnail_attachment: :blob)
    end

    def filter_by_category(scope)
      return scope if @category_slug.blank?

      scope.joins(:category).where(categories: { slug: @category_slug })
    end

    def apply_sort(scope)
      order = SORT_OPTIONS[@sort] || SORT_OPTIONS['newest']
      scope.order(order)
    end
  end
end
