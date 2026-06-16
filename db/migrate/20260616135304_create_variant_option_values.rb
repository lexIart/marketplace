class CreateVariantOptionValues < ActiveRecord::Migration[7.1]
  def change
    create_table :variant_option_values, id: :uuid do |t|
      t.references :variant, type: :uuid, null: false, foreign_key: true
      t.references :option_value, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end

    add_index :variant_option_values, %i[variant_id option_value_id], unique: true,
                                                                      name: 'index_vov_on_variant_and_option_value'
  end
end
