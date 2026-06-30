class AddSkuFieldsToVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :variants, :sku2, :string
    add_column :variants, :ean, :string
    add_index :variants, :ean, unique: true, where: 'ean IS NOT NULL'
  end
end
