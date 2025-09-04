class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :cart_items, through: :cart

  validates :email, presence: true, uniqueness: true

  after_create :create_cart

  private

  def create_cart
    build_cart.save!
  end
end
