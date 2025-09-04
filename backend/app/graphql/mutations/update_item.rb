module Mutations
  class UpdateItem < BaseMutation
    argument :cart_item_id, ID, required: true
    argument :quantity, Integer, required: true
    argument :client_mutation_id, String, required: false

    field :cart, Types::CartType, null: false
    field :errors, [String], null: false

    def resolve(cart_item_id:, quantity:, client_mutation_id: nil)
      cart_item = CartItem.find(cart_item_id)
      cart = cart_item.cart

      # Check for idempotency
      if client_mutation_id
        cache_key = "mutation:#{cart.id}:#{client_mutation_id}"
        cached_result = Rails.cache.read(cache_key)
        return cached_result if cached_result
      end

      if quantity <= 0
        return {
          cart: cart,
          errors: ["Quantity must be greater than 0"]
        }
      end

      # Check stock availability
      if quantity > cart_item.product.available_quantity
        return {
          cart: cart,
          errors: ["Insufficient stock. Available: #{cart_item.product.available_quantity}"]
        }
      end

      cart_item.update!(quantity: quantity)

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
    rescue ActiveRecord::RecordInvalid => e
      {
        cart: cart,
        errors: e.record.errors.full_messages
      }
    end
  end
end
