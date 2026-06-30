# frozen_string_literal: true

class Catalog::ProductsController < ApplicationController
  def index
    @pagy, @products = pagy(Products::CatalogQuery.new(params).call, limit: 12)
    @categories = Category.all
  end

  def show
    @product = Product.published.find_by!(slug: params[:id])
  end
end
