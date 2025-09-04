module Types
  class CartType < BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: true
    field :status, String, null: false
    field :items, [CartItemType], null: false
    field :total_items, Integer, null: false
    field :subtotal_cents, Integer, null: false
    field :updated_at, String, null: false

    def updated_at
      object.updated_at.iso8601
    end
  end
end
