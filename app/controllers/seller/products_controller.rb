class Seller::ProductsController < ApplicationController
  # Devise method to check if user is already logged in
  # If no - redirect to sign_in page
  before_action :authenticate_user!

  # To check if user role is seller (logged). If not - redirect to seed
  before_action :require_seller!

  # Only for 4 actions because in the rest of 7 actions we don't need specific user ID
  before_action :set_product, only: %i[show edit update destroy]

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
    params.require(:product).permit(
      :name, :slug, :status, :category_id, :thumbnail, :description,
      variants_attributes: %i[id price stock status]
    )
  end
end
