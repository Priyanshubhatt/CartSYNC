#!/bin/bash

# CartSYNC Setup Script
# This script sets up the CartSYNC development environment

set -e

echo "🚀 Setting up CartSYNC..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create environment files
echo "📝 Creating environment files..."

# Backend environment
cat > backend/.env << EOF
DATABASE_URL=postgres://postgres:password@db:5432/cart_sync_development
REDIS_URL=redis://redis:6379/0
RAILS_ENV=development
SECRET_KEY_BASE=$(openssl rand -hex 64)
DEVISE_SECRET_KEY=$(openssl rand -hex 64)
EOF

# Frontend environment
cat > frontend/.env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_WS_URL=ws://localhost:3000/cable
EOF

echo "✅ Environment files created"

# Build and start services
echo "🐳 Building and starting Docker services..."

docker-compose down --remove-orphans
docker-compose build
docker-compose up -d

echo "⏳ Waiting for services to be ready..."

# Wait for database to be ready
echo "📊 Waiting for database..."
until docker-compose exec -T db pg_isready -U postgres; do
  echo "Waiting for database..."
  sleep 2
done

# Wait for Redis to be ready
echo "🔴 Waiting for Redis..."
until docker-compose exec -T redis redis-cli ping; do
  echo "Waiting for Redis..."
  sleep 2
done

# Run database migrations and seed data
echo "🌱 Setting up database..."
docker-compose exec backend rails db:create db:migrate db:seed

echo "✅ Database setup complete"

# Run tests
echo "🧪 Running tests..."

# Backend tests
echo "Testing backend..."
docker-compose exec backend bundle exec rspec --format documentation

# Frontend tests
echo "Testing frontend..."
docker-compose exec frontend npm test -- --watchAll=false

echo "✅ All tests passed!"

# Display access information
echo ""
echo "🎉 CartSYNC is ready!"
echo ""
echo "📱 Frontend: http://localhost:3001"
echo "🔧 Backend API: http://localhost:3000"
echo "📊 GraphQL Playground: http://localhost:3000/graphql"
echo "❤️  Health Check: http://localhost:3000/health"
echo ""
echo "🧪 To run tests:"
echo "  Backend: docker-compose exec backend bundle exec rspec"
echo "  Frontend: docker-compose exec frontend npm test"
echo ""
echo "📊 To run load tests:"
echo "  k6 run load-tests/cart-sync-test.js"
echo ""
echo "🛑 To stop: docker-compose down"
echo ""

# Show logs
echo "📋 Showing service logs (Ctrl+C to exit)..."
docker-compose logs -f
