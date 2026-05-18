class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.datetime :published_at
      t.references :seller, null: false, type: :uuid, foreign_key: { to_table: 'users' }
      t.references :category, foreign_key: true

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :status
    add_index :products, :published_at
    add_index :products, %i[seller_id status]
    add_index :products, %i[category_id status]
  end
end
