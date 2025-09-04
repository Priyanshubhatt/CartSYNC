class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates :title, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :sku, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where('stock_quantity > 0') }

  def in_stock?
    stock_quantity > 0
  end

  def available_quantity
    [stock_quantity, 0].max
  end
end
