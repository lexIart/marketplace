class Seller::ProductsController < ApplicationController
  # Devise method to check if user is already logged in
  # If no - redirect to sign_in page
  before_action :authenticate_user!

  # To check if user role is seller (logged). If not - redirect to seed
  before_action :require_seller!

  # Only actions that don't need any specific user ID's
  before_action :set_product, only: %i[show edit update destroy generate_variants add_simple_variant]

  def index
    # Pundit [ProductPolicy::Scope#resolve]
    @products = policy_scope(Product)
  end

  def show
    # Pundit [ProductPolicy#show?]
    authorize @product
  end

  def new
    @product = Product.new
    # Pundit [ProductPolicy#new?]
    authorize @product
  end

  def create
    # Just product creation without save in DB
    @product = current_user.products.build(product_params)
    # Pundit [ProductPolicy#create?]
    authorize @product

    if @product.save
      redirect_to seller_product_path(@product), notice: 'Товар создан.'
    else
      # Render for again with errors (422)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product

    if @product.update(product_params)
      redirect_to seller_product_path(@product), notice: 'Товар обновлён.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.destroy
    redirect_to seller_products_path, notice: 'Товар удалён.'
  end

  def add_simple_variant
    authorize @product

    simple_sku = @product.slug.upcase

    if @product.variants.exists?(sku: simple_sku)
      redirect_to seller_product_path(@product), alert: 'Простой вариант уже существует.' and return
    end

    @product.variants.create!(sku: simple_sku, price: 0, stock: 0)
    # lets redirect him to product edit
    redirect_to edit_seller_product_path(@product), notice: 'Простой вариант добавлен. Укажите цену и остаток.'
  end

  def generate_variants
    authorize @product
    # to_unsafe_h to avoid params obj permit decline because selected options - is a data from user form
    selected_options = params[:selected_options]&.to_unsafe_h || {}

    if selected_options.blank?
      redirect_to seller_product_path(@product), alert: 'Выберите хотя бы одну опцию.' and return
    end

    selected_options.each_key do |option_type_id|
      @product.product_option_types.find_or_create_by!(option_type_id: option_type_id)
    end

    result = Products::VariantGenerator.call(
      @product,
      selected_options,
      default_price: params[:default_price],
      default_stock: params[:default_stock] || 0
    )

    redirect_to seller_product_path(@product), notice: result.message
  end

  private

  def set_product
    # current_user from Devise [ApplicationController < ActionController::Base] (before_action :authenticate_user!)
    # @product came from before_action :set_product
    @product = current_user.products.find_by!(slug: params[:id])
  end

  def require_seller!
    redirect_to root_path, alert: 'Доступ только для продавцов.' unless current_user.seller?
  end

  def product_params
    permitted = params.require(:product).permit(
      :name, :slug, :status, :category_id, :thumbnail, :description,
      variants_attributes: %i[id price stock status],
      specifications: {}
    )
    # because of ActionController::UnfilteredParameters
    specs = params.dig(:product, :specifications)&.to_unsafe_h || {}
    permitted[:specifications] = specs.reject { |k, v| k.blank? || k.start_with?('__new_') || v.blank? }

    permitted
  end
end
