# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_260_701_121_041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'action_text_rich_texts', force: :cascade do |t|
    t.string 'name', null: false
    t.text 'body'
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[record_type record_id name], name: 'index_action_text_rich_texts_uniqueness', unique: true
  end

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'cart_items', force: :cascade do |t|
    t.bigint 'cart_id', null: false
    t.bigint 'variant_id', null: false
    t.integer 'quantity', default: 1, null: false
    t.decimal 'unit_price', precision: 10, scale: 2, null: false
    t.integer 'lock_version', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[cart_id variant_id], name: 'index_cart_items_on_cart_id_and_variant_id', unique: true
    t.index ['cart_id'], name: 'index_cart_items_on_cart_id'
    t.index ['variant_id'], name: 'index_cart_items_on_variant_id'
  end

  create_table 'carts', force: :cascade do |t|
    t.uuid 'user_id'
    t.string 'token', null: false
    t.datetime 'expires_at', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['token'], name: 'index_carts_on_token', unique: true
    t.index ['user_id'], name: 'index_carts_on_user_id'
  end

  create_table 'categories', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'slug', null: false
    t.string 'description'
    t.string 'text'
    t.bigint 'parent_id'
    t.integer 'position', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[parent_id position], name: 'index_categories_on_parent_id_and_position'
    t.index ['parent_id'], name: 'index_categories_on_parent_id'
    t.index ['position'], name: 'index_categories_on_position'
    t.index ['slug'], name: 'index_categories_on_slug', unique: true
  end

  create_table 'option_types', force: :cascade do |t|
    t.string 'name'
    t.string 'presentation'
    t.integer 'position'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'option_values', force: :cascade do |t|
    t.bigint 'option_type_id', null: false
    t.string 'name'
    t.string 'presentation'
    t.integer 'position'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['option_type_id'], name: 'index_option_values_on_option_type_id'
  end

  create_table 'product_categories', force: :cascade do |t|
    t.bigint 'product_id', null: false
    t.bigint 'category_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['category_id'], name: 'index_product_categories_on_category_id'
    t.index %w[product_id category_id], name: 'index_product_categories_on_product_and_category', unique: true
    t.index ['product_id'], name: 'index_product_categories_on_product_id'
  end

  create_table 'product_option_types', force: :cascade do |t|
    t.bigint 'product_id', null: false
    t.bigint 'option_type_id', null: false
    t.integer 'position'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['option_type_id'], name: 'index_product_option_types_on_option_type_id'
    t.index ['product_id'], name: 'index_product_option_types_on_product_id'
  end

  create_table 'products', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'slug', null: false
    t.text 'description'
    t.integer 'status', default: 0, null: false
    t.datetime 'published_at'
    t.uuid 'seller_id', null: false
    t.bigint 'category_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.jsonb 'specifications', default: {}, null: false
    t.index %w[category_id status], name: 'index_products_on_category_id_and_status'
    t.index ['category_id'], name: 'index_products_on_category_id'
    t.index ['published_at'], name: 'index_products_on_published_at'
    t.index %w[seller_id status], name: 'index_products_on_seller_id_and_status'
    t.index ['seller_id'], name: 'index_products_on_seller_id'
    t.index ['slug'], name: 'index_products_on_slug', unique: true
    t.index ['status'], name: 'index_products_on_status'
  end

  create_table 'users', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string 'current_sign_in_ip'
    t.string 'last_sign_in_ip'
    t.string 'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string 'unconfirmed_email'
    t.string 'first_name', null: false
    t.string 'last_name', null: false
    t.string 'role', default: 'buyer', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'username', null: false
    t.index ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
    t.index ['role'], name: 'index_users_on_role'
    t.index ['username'], name: 'index_users_on_username', unique: true
  end

  create_table 'variant_option_values', force: :cascade do |t|
    t.bigint 'variant_id', null: false
    t.bigint 'option_value_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['option_value_id'], name: 'index_variant_option_values_on_option_value_id'
    t.index ['variant_id'], name: 'index_variant_option_values_on_variant_id'
  end

  create_table 'variants', force: :cascade do |t|
    t.bigint 'product_id', null: false
    t.string 'sku', null: false
    t.decimal 'price', precision: 10, scale: 2, null: false
    t.integer 'stock', default: 0, null: false
    t.string 'status', default: 'active'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'sku2'
    t.string 'ean'
    t.index ['ean'], name: 'index_variants_on_ean', unique: true, where: '(ean IS NOT NULL)'
    t.index %w[product_id status], name: 'index_variants_on_product_id_and_status'
    t.index ['product_id'], name: 'index_variants_on_product_id'
    t.index ['sku'], name: 'index_variants_on_sku', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'cart_items', 'carts'
  add_foreign_key 'cart_items', 'variants'
  add_foreign_key 'carts', 'users'
  add_foreign_key 'categories', 'categories', column: 'parent_id'
  add_foreign_key 'option_values', 'option_types'
  add_foreign_key 'product_categories', 'categories'
  add_foreign_key 'product_categories', 'products'
  add_foreign_key 'product_option_types', 'option_types'
  add_foreign_key 'product_option_types', 'products'
  add_foreign_key 'products', 'categories'
  add_foreign_key 'products', 'users', column: 'seller_id'
  add_foreign_key 'variant_option_values', 'option_values'
  add_foreign_key 'variant_option_values', 'variants'
  add_foreign_key 'variants', 'products'
end
