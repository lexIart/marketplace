class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[update destroy]

  def create
    variant = Variant.find(params[:variant_id])

    existing = current_cart.cart_items.find_by(variant_id: variant.id)

    if existing
      new_qty = existing.quantity + params.fetch(:quantity, 1).to_i
      update_item(existing, new_qty)
    else
      item = current_cart.cart_items.build(variant: variant, quantity: params.fetch(:quantity, 1).to_i)

      if item.quantity > variant.stock
        render_error("Недостаточно товара на складе (доступно: #{variant.stock})")
        return
      end

      if item.save
        current_cart.touch_expiry!
        respond_to_success("«#{variant.product.name}» добавлен в корзину")
      else
        render_error(item.errors.full_messages.to_sentence)
      end
    end
  end

  def update
    new_qty = params.require(:cart_item).require(:quantity).to_i
    update_item(@cart_item, new_qty)
  end

  def destroy
    @cart_item.destroy
    current_cart.touch_expiry!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@cart_item),
          turbo_stream.replace("cart_summary", partial: "carts/summary"),
          turbo_stream.replace("cart_nav_count", partial: "carts/nav_count")
        ]
      end
      format.html { redirect_to cart_path, notice: "Товар удалён из корзины" }
    end
  end

  private

  def set_cart_item
    @cart_item = current_cart.cart_items.find(params[:id])
  end

  def update_item(item, new_qty)
    if new_qty > item.variant.stock
      render_error("Недостаточно товара на складе (доступно: #{item.variant.stock})")
      return
    end

    begin
      item.update!(quantity: new_qty)
      current_cart.touch_expiry!

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(item),
            turbo_stream.replace("cart_summary", partial: "carts/summary"),
            turbo_stream.replace("cart_nav_count", partial: "carts/nav_count")
          ]
        end
        format.html { redirect_to cart_path }
      end
    rescue ActiveRecord::StaleObjectError
      item.reload
      render_error("Корзина была обновлена в другой вкладке. Попробуйте ещё раз.")
    end
  end

  def respond_to_success(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("cart_nav_count", partial: "carts/nav_count"),
          turbo_stream.replace("flash", partial: "shared/flash", locals: { notice: message })
        ]
      end
      format.html { redirect_to cart_path, notice: message }
    end
  end

  def render_error(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "flash",
          partial: "shared/flash",
          locals: { alert: message }
        )
      end
      format.html { redirect_back_or_to cart_path, alert: message }
    end
  end
end
