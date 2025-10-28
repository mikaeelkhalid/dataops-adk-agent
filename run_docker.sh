#!/bin/bash

# DataOps Agent - Docker Runner
echo "🐳 Starting DataOps GitHub Analysis Agent with Docker..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if environment file exists
if [ ! -f ".env.docker" ]; then
    echo "❌ Environment file .env.docker not found"
    echo "Please create .env.docker with your Google Cloud configuration:"
    echo "  - GOOGLE_CLOUD_PROJECT"
    echo "  - GOOGLE_CLOUD_LOCATION"
    echo "  - AGENT_ENGINE_ID"
    echo "  - GOOGLE_CLOUD_STORAGE_BUCKET"
    exit 1
fi

# Load environment variables
export $(cat .env.docker | grep -v '#' | xargs)

echo "🔧 Building Docker image..."
docker-compose build

echo "🚀 Starting Streamlit app..."
echo "🌐 App will be available at http://localhost:8501"
echo "💡 Use Ctrl+C to stop the application"
echo ""

# Start the application
docker-compose up