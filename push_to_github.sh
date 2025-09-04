#!/bin/bash

echo "🚀 Pushing CartSYNC to GitHub..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Initializing..."
    git init
fi

# Add all files
echo "📁 Adding files to git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "✅ No changes to commit"
else
    echo "💾 Committing changes..."
    git commit -m "Add complete CartSYNC project

- Rails backend with GraphQL API
- Next.js frontend with real-time updates  
- Redis pub/sub for instant messaging
- ActionCable WebSocket support
- Docker configuration
- Comprehensive test suite
- CI/CD pipeline
- Load testing with k6
- Production-ready setup"
fi

# Add remote if not exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "🔗 Adding remote origin..."
    git remote add origin https://github.com/Priyanshubhatt/CartSYNC.git
fi

# Push to GitHub
echo "⬆️  Pushing to GitHub..."
git push origin main --force

echo "✅ Successfully pushed to GitHub!"
echo "🌐 Repository: https://github.com/Priyanshubhatt/CartSYNC"

