class AddForeignKeyToProductCategories < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :product_categories, :products
  end
end
