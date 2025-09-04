require 'rails_helper'

RSpec.describe Mutations::AddItem, type: :request do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user) }
  let(:product) { create(:product, stock_quantity: 10) }
  let(:query) do
    <<~GQL
      mutation AddItem($cartId: ID!, $productId: ID!, $quantity: Int!, $clientMutationId: String) {
        addItem(input: {
          cartId: $cartId
          productId: $productId
          quantity: $quantity
          clientMutationId: $clientMutationId
        }) {
          cart {
            id
            totalItems
            subtotalCents
            items {
              id
              product { id title }
              quantity
              unitPriceCents
            }
          }
          errors
        }
      }
    GQL
  end

  before do
    allow(CartEvents).to receive(:publish)
  end

  context 'when adding a new item' do
    let(:variables) do
      {
        cartId: cart.id,
        productId: product.id,
        quantity: 2,
        clientMutationId: 'test-123'
      }
    end

    it 'creates a new cart item' do
      expect do
        post '/graphql', params: { query: query, variables: variables }
      end.to change { cart.cart_items.count }.by(1)
    end

    it 'returns the updated cart' do
      post '/graphql', params: { query: query, variables: variables }
      
      result = JSON.parse(response.body)
      expect(result['data']['addItem']['cart']['totalItems']).to eq(2)
      expect(result['data']['addItem']['errors']).to be_empty
    end

    it 'publishes cart change event' do
      post '/graphql', params: { query: query, variables: variables }
      expect(CartEvents).to have_received(:publish).with(cart.id)
    end
  end

  context 'when updating existing item' do
    let!(:existing_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
    let(:variables) do
      {
        cartId: cart.id,
        productId: product.id,
        quantity: 3,
        clientMutationId: 'test-456'
      }
    end

    it 'updates the existing item quantity' do
      expect do
        post '/graphql', params: { query: query, variables: variables }
      end.not_to change { cart.cart_items.count }

      existing_item.reload
      expect(existing_item.quantity).to eq(4) # 1 + 3
    end
  end

  context 'when quantity exceeds stock' do
    let(:variables) do
      {
        cartId: cart.id,
        productId: product.id,
        quantity: 15, # More than stock_quantity of 10
        clientMutationId: 'test-789'
      }
    end

    it 'returns an error' do
      post '/graphql', params: { query: query, variables: variables }
      
      result = JSON.parse(response.body)
      expect(result['data']['addItem']['errors']).to include('Insufficient stock. Available: 10')
    end
  end

  context 'when cart does not exist' do
    let(:variables) do
      {
        cartId: 'non-existent',
        productId: product.id,
        quantity: 1,
        clientMutationId: 'test-999'
      }
    end

    it 'returns an error' do
      post '/graphql', params: { query: query, variables: variables }
      
      result = JSON.parse(response.body)
      expect(result['errors']).to be_present
    end
  end

  context 'with idempotency' do
    let(:variables) do
      {
        cartId: cart.id,
        productId: product.id,
        quantity: 2,
        clientMutationId: 'idempotent-test'
      }
    end

    it 'returns cached result on duplicate request' do
      post '/graphql', params: { query: query, variables: variables }
      first_result = JSON.parse(response.body)

      post '/graphql', params: { query: query, variables: variables }
      second_result = JSON.parse(response.body)

      expect(first_result).to eq(second_result)
    end
  end
end
