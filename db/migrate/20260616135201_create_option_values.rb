class CreateOptionValues < ActiveRecord::Migration[7.1]
  def change
    create_table :option_values, id: :uuid do |t|
      t.references :option_type, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :presentation, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :option_values, %i[option_type_id name], unique: true
    add_index :option_values, :position
  end
end
