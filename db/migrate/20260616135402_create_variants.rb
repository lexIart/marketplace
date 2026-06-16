class CreateVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :variants, id: :uuid do |t|
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock, default: 0, null: false
      t.string :status, default: 'active'
      t.timestamps
    end

    add_index :variants, :sku, unique: true
    add_index :variants, %i[product_id status]
  end
end
