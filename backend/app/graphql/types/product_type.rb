module Types
  class ProductType < BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :sku, String, null: false
    field :price_cents, Integer, null: false
    field :stock_quantity, Integer, null: false
    field :active, Boolean, null: false
    field :in_stock, Boolean, null: false
    field :available_quantity, Integer, null: false
  end
end
