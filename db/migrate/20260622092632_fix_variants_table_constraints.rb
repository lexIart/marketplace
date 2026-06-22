class FixVariantsTableConstraints < ActiveRecord::Migration[7.1]
  def up
    execute "UPDATE variants SET status = 'active' WHERE status IS NULL"

    change_column :variants, :sku,   :string,  null: false
    change_column :variants, :price, :decimal, precision: 10, scale: 2, null: false
    change_column :variants, :stock, :integer, default: 0, null: false

    change_column_default :variants, :status, 'active'

    add_index :variants, :sku, unique: true unless index_exists?(:variants, :sku)
    add_index :variants, %i[product_id status] unless index_exists?(:variants, %i[product_id status])
  end

  def down
    remove_index :variants, :sku, if_exists: true
    remove_index :variants, %i[product_id status], if_exists: true

    change_column_default :variants, :status, nil
    change_column :variants, :sku,   :string,  null: true
    change_column :variants, :price, :decimal, null: true
    change_column :variants, :stock, :integer, default: nil, null: true
  end
end
