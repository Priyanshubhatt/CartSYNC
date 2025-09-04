FactoryBot.define do
  factory :product do
    title { Faker::Commerce.product_name }
    description { Faker::Commerce.material }
    sku { Faker::Alphanumeric.alphanumeric(number: 10) }
    price_cents { Faker::Number.between(from: 1000, to: 50000) }
    stock_quantity { Faker::Number.between(from: 0, to: 100) }
    active { true }
  end
end
