require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:unit_price_cents) }
    it { should validate_numericality_of(:unit_price_cents).is_greater_than(0) }
    it { should validate_uniqueness_of(:product_id).scoped_to(:cart_id) }
  end

  describe '#total_price_cents' do
    let(:cart_item) { create(:cart_item, quantity: 3, unit_price_cents: 1000) }

    it 'returns quantity multiplied by unit price' do
      expect(cart_item.total_price_cents).to eq(3000)
    end
  end

  describe 'callbacks' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    it 'publishes cart change after commit' do
      expect(CartEvents).to receive(:publish).with(cart.id)
      create(:cart_item, cart: cart, product: product)
    end
  end
end
