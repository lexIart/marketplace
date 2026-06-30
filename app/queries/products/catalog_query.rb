# frozen_string_literal: true

module Products
  class CatalogQuery
    SORT_OPTIONS = {
      'newest'    => { published_at: :desc },
      'oldest'    => { published_at: :asc },
      'name_asc'  => { name: :asc },
      'name_desc' => { name: :desc }
    }.freeze

    def initialize(params = {})
      @category_id = params[:category_id]
      @sort        = params[:sort]
    end

    def call
      scope = base_scope
      scope = filter_by_category(scope)
      scope = apply_sort(scope)
      scope
    end

    private

    def base_scope
      Product.published.includes(:category, :variants, thumbnail_attachment: :blob)
    end

    def filter_by_category(scope)
      return scope if @category_id.blank?

      scope.where(category_id: @category_id)
    end

    def apply_sort(scope)
      order = SORT_OPTIONS[@sort] || SORT_OPTIONS['newest']
      scope.order(order)
    end
  end
end
