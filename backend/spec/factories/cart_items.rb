FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price_cents { product.price_cents }
  end
end
