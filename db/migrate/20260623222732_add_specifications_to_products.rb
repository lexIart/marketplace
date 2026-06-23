class AddSpecificationsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :specifications, :jsonb, default: {}, null: false
  end
end
