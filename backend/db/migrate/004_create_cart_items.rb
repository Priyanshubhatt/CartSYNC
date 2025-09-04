class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.timestamps null: false
    end

    add_index :cart_items, [:cart_id, :product_id], unique: true
    add_index :cart_items, :cart_id
    add_index :cart_items, :updated_at
  end
end
