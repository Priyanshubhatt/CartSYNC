class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user, null: true, foreign_key: true
      t.string :status, null: false, default: 'active'
      t.timestamps null: false
    end

    add_index :carts, :user_id
    add_index :carts, :status
    add_index :carts, :updated_at
  end
end
