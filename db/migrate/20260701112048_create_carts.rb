class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.uuid :user_id
      t.string :token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :carts, :token, unique: true
    add_index :carts, :user_id
    # FK restrict to avoid trash-links to be created (bd level)
    # /has_one :cart, dependent: :destroy/ - to avoid this restriction while deliting of user
    add_foreign_key :carts, :users, column: :user_id
  end
end
