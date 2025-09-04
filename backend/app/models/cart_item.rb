class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }

  after_commit :publish_cart_change

  def total_price_cents
    quantity * unit_price_cents
  end

  private

  def publish_cart_change
    cart.publish_change
  end
end
