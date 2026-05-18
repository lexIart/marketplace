class CreateProductCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :product_categories, [:product_id, :category_id], unique: true, name: "index_product_categories_on_product_and_category"
  end
end
