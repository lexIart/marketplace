# frozen_string_literal: true

class Catalog::ProductsController < ApplicationController
  def index
    @products = Product.published
                       .includes(:category, :variants, thumbnail_attachment: :blob)
    @categories = Category.all
  end

  def show
    @product = Product.published.find_by!(slug: params[:id])
  end
end
