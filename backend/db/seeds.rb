# Create sample products
products = [
  { title: "Wireless Headphones", description: "High-quality wireless headphones with noise cancellation", sku: "WH-001", price_cents: 19999, stock_quantity: 50 },
  { title: "Smart Watch", description: "Fitness tracking smart watch with heart rate monitor", sku: "SW-002", price_cents: 29999, stock_quantity: 30 },
  { title: "Laptop Stand", description: "Adjustable aluminum laptop stand for ergonomic computing", sku: "LS-003", price_cents: 4999, stock_quantity: 100 },
  { title: "Mechanical Keyboard", description: "RGB mechanical keyboard with blue switches", sku: "MK-004", price_cents: 12999, stock_quantity: 25 },
  { title: "Gaming Mouse", description: "High-precision gaming mouse with customizable RGB lighting", sku: "GM-005", price_cents: 7999, stock_quantity: 75 },
  { title: "USB-C Hub", description: "Multi-port USB-C hub with HDMI, USB, and charging", sku: "UH-006", price_cents: 8999, stock_quantity: 40 },
  { title: "Monitor Arm", description: "Dual monitor arm with gas spring technology", sku: "MA-007", price_cents: 15999, stock_quantity: 20 },
  { title: "Desk Mat", description: "Large desk mat with water-resistant surface", sku: "DM-008", price_cents: 2999, stock_quantity: 60 }
]

products.each do |product_attrs|
  Product.find_or_create_by(sku: product_attrs[:sku]) do |product|
    product.assign_attributes(product_attrs)
  end
end

puts "Created #{Product.count} products"

# Create a test user
user = User.find_or_create_by(email: "test@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

puts "Created test user: #{user.email}"

# Create a sample cart for the test user
if user.cart.nil?
  cart = user.create_cart!
  puts "Created cart for test user: #{cart.id}"
end
