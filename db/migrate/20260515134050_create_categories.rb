class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :description
      t.string :text
      # parent_id generated
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, [:parent_id, :position]
    add_index :categories, :position
  end
end
