require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[active abandoned completed]) }
  end

  describe 'scopes' do
    let!(:active_cart) { create(:cart, status: 'active') }
    let!(:abandoned_cart) { create(:cart, status: 'abandoned') }
    let!(:user_cart) { create(:cart, :with_user) }
    let!(:anonymous_cart) { create(:cart, :anonymous) }

    describe '.active' do
      it 'returns only active carts' do
        expect(Cart.active).to include(active_cart)
        expect(Cart.active).not_to include(abandoned_cart)
      end
    end

    describe '.for_user' do
      it 'returns carts for a specific user' do
        expect(Cart.for_user(user_cart.user)).to include(user_cart)
        expect(Cart.for_user(user_cart.user)).not_to include(anonymous_cart)
      end
    end

    describe '.anonymous' do
      it 'returns anonymous carts' do
        expect(Cart.anonymous).to include(anonymous_cart)
        expect(Cart.anonymous).not_to include(user_cart)
      end
    end
  end

  describe '#total_items' do
    let(:cart) { create(:cart) }
    let!(:item1) { create(:cart_item, cart: cart, quantity: 2) }
    let!(:item2) { create(:cart_item, cart: cart, quantity: 3) }

    it 'returns the sum of all item quantities' do
      expect(cart.total_items).to eq(5)
    end
  end

  describe '#subtotal_cents' do
    let(:cart) { create(:cart) }
    let!(:item1) { create(:cart_item, cart: cart, quantity: 2, unit_price_cents: 1000) }
    let!(:item2) { create(:cart_item, cart: cart, quantity: 3, unit_price_cents: 2000) }

    it 'returns the sum of all item totals' do
      expect(cart.subtotal_cents).to eq(8000) # (2 * 1000) + (3 * 2000)
    end
  end

  describe '#merge_with!' do
    let(:cart1) { create(:cart) }
    let(:cart2) { create(:cart) }
    let(:product) { create(:product) }

    before do
      create(:cart_item, cart: cart1, product: product, quantity: 2)
      create(:cart_item, cart: cart2, product: product, quantity: 3)
    end

    it 'merges items from another cart' do
      expect { cart1.merge_with!(cart2) }.to change { cart1.cart_items.count }.by(1)
      expect(cart1.cart_items.find_by(product: product).quantity).to eq(5)
    end

    it 'destroys the other cart' do
      expect { cart1.merge_with!(cart2) }.to change { Cart.count }.by(-1)
    end

    it 'returns self' do
      expect(cart1.merge_with!(cart2)).to eq(cart1)
    end
  end
end
