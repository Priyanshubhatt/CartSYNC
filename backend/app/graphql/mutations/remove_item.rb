module Mutations
  class RemoveItem < BaseMutation
    argument :cart_item_id, ID, required: true
    argument :client_mutation_id, String, required: false

    field :cart, Types::CartType, null: false
    field :errors, [String], null: false

    def resolve(cart_item_id:, client_mutation_id: nil)
      cart_item = CartItem.find(cart_item_id)
      cart = cart_item.cart

      # Check for idempotency
      if client_mutation_id
        cache_key = "mutation:#{cart.id}:#{client_mutation_id}"
        cached_result = Rails.cache.read(cache_key)
        return cached_result if cached_result
      end

      cart_item.destroy!

      result = {
        cart: cart.reload,
        errors: []
      }

      # Cache result for idempotency
      if client_mutation_id
        Rails.cache.write(cache_key, result, expires_in: 10.minutes)
      end

      result
    rescue ActiveRecord::RecordNotFound => e
      {
        cart: cart,
        errors: [e.message]
      }
    end
  end
end
