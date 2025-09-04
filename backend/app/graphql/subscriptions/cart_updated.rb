module Subscriptions
  class CartUpdated < BaseSubscription
    argument :cart_id, ID, required: true
    field :cart, Types::CartType, null: false

    def subscribe(cart_id:)
      # Subscribe to the cart updates channel
      { cart: Cart.find(cart_id) }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Cart not found"
    end

    def update(cart_id:)
      # Return the updated cart when changes occur
      { cart: Cart.find(cart_id) }
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
