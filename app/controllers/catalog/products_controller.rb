# frozen_string_literal: true

class Catalog::ProductsController < ApplicationController
  def index
    @pagy, @products = pagy(Products::CatalogQuery.new(params).call, limit: 12)
    @categories = Category.all
  end

  def show
    @product = Product.published
                      .includes(:thumbnail_attachment,
                                variants: [:images_attachments, { option_values: :option_type }])
                      .find_by!(slug: params[:id])
  end
end
