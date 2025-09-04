module Types
  class TotalsType < BaseObject
    field :subtotal_cents, Integer, null: false
    field :item_count, Integer, null: false
  end
end
