class CartsController < ApplicationController
  def show
    @cart_items = current_cart.cart_items
                              .includes(variant: [:product, { images_attachments: :blob }, :variant_option_values])
                              .order(:created_at)
  end
end
