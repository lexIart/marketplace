class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :cart_items, %i[cart_id variant_id], unique: true
  end
end
