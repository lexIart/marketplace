class CreateProductOptionTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :product_option_types, id: :uuid do |t|
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.references :option_type, type: :uuid, null: false, foreign_key: true
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :product_option_types, %i[product_id option_type_id], unique: true
  end
end
