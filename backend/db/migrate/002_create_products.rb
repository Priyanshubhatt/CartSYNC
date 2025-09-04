class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.text :description
      t.string :sku, null: false
      t.integer :price_cents, null: false
      t.integer :stock_quantity, default: 0
      t.boolean :active, default: true
      t.timestamps null: false
    end

    add_index :products, :sku, unique: true
    add_index :products, :active
    add_index :products, :stock_quantity
  end
end
