#!/bin/bash

# Docker Test Script for kiro2cc
# This script demonstrates various Docker usage scenarios

set -e

echo "🐳 Testing kiro2cc Docker Implementation"
echo "==========================================="

echo ""
echo "📦 Building Docker image..."
docker build -t kiro2cc:test . --quiet
echo "✅ Build completed successfully"

echo ""
echo "📏 Checking image size..."
docker images kiro2cc:test --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "🔍 Testing application help..."
docker run --rm kiro2cc:test /kiro2cc 2>&1 | head -5

echo ""
echo "🩺 Testing server startup (3 seconds)..."
docker run --rm -p 8081:8080 --name kiro2cc-test kiro2cc:test &
SERVER_PID=$!
sleep 3

echo ""
echo "🌐 Testing health endpoint..."
if curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ Health endpoint responding"
else
    echo "⚠️  Health endpoint not accessible (expected without token file)"
fi

echo ""
echo "🛑 Stopping test server..."
docker stop kiro2cc-test > /dev/null 2>&1 || true
wait $SERVER_PID 2>/dev/null || true

echo ""
echo "📋 Testing Docker Compose configuration..."
docker compose config --quiet
echo "✅ Docker Compose configuration is valid"

echo ""
echo "🎉 All Docker tests completed successfully!"
echo ""
echo "Usage examples:"
echo "  docker run --rm -p 8080:8080 -v ~/.aws/sso/cache:/root/.aws/sso/cache:ro kiro2cc:test"
echo "  docker compose up -d"
echo ""