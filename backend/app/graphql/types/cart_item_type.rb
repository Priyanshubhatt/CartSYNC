module Types
  class CartItemType < BaseObject
    field :id, ID, null: false
    field :product, ProductType, null: false
    field :quantity, Integer, null: false
    field :unit_price_cents, Integer, null: false
    field :total_price_cents, Integer, null: false
  end
end
