module Queries
  class CartQueries < BaseQuery
    field :current_cart, Types::CartType, null: false do
      argument :cart_id, ID, required: true
    end

    field :cart_totals, Types::TotalsType, null: false do
      argument :cart_id, ID, required: true
    end

    field :products, [Types::ProductType], null: false do
      argument :active, Boolean, required: false, default_value: true
    end

    def current_cart(cart_id:)
      Cart.find(cart_id)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Cart not found"
    end

    def cart_totals(cart_id:)
      cart = Cart.find(cart_id)
      {
        subtotal_cents: cart.subtotal_cents,
        item_count: cart.total_items
      }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Cart not found"
    end

    def products(active: true)
      scope = Product.all
      scope = scope.active if active
      scope
    end
  end
end
