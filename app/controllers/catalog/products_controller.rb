# frozen_string_literal: true

class Catalog::ProductsController < ApplicationController
  def index
    @pagy, @products = pagy(
      Product.published.includes(:category, :variants, thumbnail_attachment: :blob),
      limit: 12
    )
    @categories = Category.all
  end

  def show
    @product = Product.published.find_by!(slug: params[:id])
  end
end
