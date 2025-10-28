#!/bin/bash

# DataOps Agent - Production Docker Runner
echo "🐳 Starting DataOps Agent in Production Mode..."

# Set production environment
export ENVIRONMENT=production

# Build production image
echo "🔨 Building production image..."
docker build -t dataops-agent:latest .

# Run in production mode
echo "🚀 Starting production container..."
docker run -d \
  --name dataops-agent-prod \
  --restart unless-stopped \
  -p 8501:8501 \
  --env-file .env.docker \
  -e ENVIRONMENT=production \
  dataops-agent:latest

echo "✅ Production container started!"
echo "🌐 App available at http://localhost:8501"
echo "📋 Container name: dataops-agent-prod"
echo ""
echo "Useful commands:"
echo "  View logs: docker logs -f dataops-agent-prod"
echo "  Stop: docker stop dataops-agent-prod"
echo "  Remove: docker rm dataops-agent-prod"