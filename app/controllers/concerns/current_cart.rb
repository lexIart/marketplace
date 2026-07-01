module CurrentCart
  extend ActiveSupport::Concern

  included do
    before_action :set_cart
    helper_method :current_cart
  end

  private

  def current_cart
    @current_cart
  end

  def set_cart
    if user_signed_in?
      @current_cart = find_or_create_user_cart
    else
      @current_cart = find_or_create_guest_cart
    end
  end

  def find_or_create_user_cart
    cart = current_user.cart || current_user.create_cart!

    # Если у гостя была корзина — сливаем её в корзину пользователя
    if (token = session[:cart_token]) && (guest_cart = Cart.find_by(token: token, user_id: nil))
      cart.merge_guest_cart!(guest_cart)
      session.delete(:cart_token)
    end

    cart.touch_expiry!
    cart
  end

  def find_or_create_guest_cart
    token = session[:cart_token]
    cart = token ? Cart.find_by(token: token) : nil

    if cart.nil? || !cart.active?
      cart = Cart.create!(expires_at: Cart::EXPIRY_DAYS.days.from_now)
      session[:cart_token] = cart.token
    end

    cart
  end
end
