class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :status, presence: true, inclusion: { in: %w[active abandoned completed] }

  scope :active, -> { where(status: 'active') }
  scope :for_user, ->(user) { where(user: user) }
  scope :anonymous, -> { where(user: nil) }

  def total_items
    cart_items.sum(:quantity)
  end

  def subtotal_cents
    cart_items.sum { |item| item.quantity * item.unit_price_cents }
  end

  def merge_with!(other_cart)
    return self if other_cart == self

    other_cart.cart_items.each do |other_item|
      existing_item = cart_items.find_by(product_id: other_item.product_id)
      
      if existing_item
        existing_item.update!(quantity: existing_item.quantity + other_item.quantity)
      else
        cart_items.create!(
          product_id: other_item.product_id,
          quantity: other_item.quantity,
          unit_price_cents: other_item.unit_price_cents
        )
      end
    end

    other_cart.destroy!
    self
  end

  def publish_change
    CartEvents.publish(id)
  end
end
