module Mutations
  class AddItem < BaseMutation
    argument :cart_id, ID, required: true
    argument :product_id, ID, required: true
    argument :quantity, Integer, required: true
    argument :client_mutation_id, String, required: false

    field :cart, Types::CartType, null: false
    field :errors, [String], null: false

    def resolve(cart_id:, product_id:, quantity:, client_mutation_id: nil)
      # Check for idempotency
      if client_mutation_id
        cache_key = "mutation:#{cart_id}:#{client_mutation_id}"
        cached_result = Rails.cache.read(cache_key)
        return cached_result if cached_result
      end

      cart = Cart.find(cart_id)
      product = Product.find(product_id)

      # Validate quantity
      if quantity <= 0
        return {
          cart: cart,
          errors: ["Quantity must be greater than 0"]
        }
      end

      # Check stock availability
      if quantity > product.available_quantity
        return {
          cart: cart,
          errors: ["Insufficient stock. Available: #{product.available_quantity}"]
        }
      end

      # Use upsert to handle concurrency
      cart_item = CartItem.find_or_initialize_by(cart: cart, product: product)
      
      if cart_item.persisted?
        new_quantity = cart_item.quantity + quantity
        if new_quantity > product.available_quantity
          return {
            cart: cart,
            errors: ["Insufficient stock. Available: #{product.available_quantity}"]
          }
        end
        cart_item.update!(quantity: new_quantity, unit_price_cents: product.price_cents)
      else
        cart_item.assign_attributes(
          quantity: quantity,
          unit_price_cents: product.price_cents
        )
        cart_item.save!
      end

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
