#!/bin/bash

# DataOps ADK Agent - Quick Setup Script
echo "🚀 DataOps ADK Agent - Quick Setup"
echo "=================================="

# Check Python version
python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
if [[ -z "$python_version" ]]; then
    echo "❌ Python 3 not found. Please install Python 3.12+ first."
    exit 1
fi

echo "✅ Found Python $python_version"

# Check if UV is installed
if ! command -v uv &> /dev/null; then
    echo "📦 Installing UV package manager..."
    pip install uv
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install UV. Please install manually: pip install uv"
        exit 1
    fi
fi

echo "✅ UV package manager ready"

# Initialize project if needed
if [ ! -f "pyproject.toml" ]; then
    echo "❌ pyproject.toml not found. Are you in the right directory?"
    exit 1
fi

# Sync dependencies
echo "📚 Installing dependencies..."
uv sync

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"

# Create environment files if they don't exist
if [ ! -f "dataops/.env" ]; then
    echo "📝 Creating environment configuration..."
    cp dataops/.env.example dataops/.env
    echo "⚠️  Please edit dataops/.env with your Google Cloud configuration"
fi

if [ ! -f ".env.docker" ]; then
    cp .env.docker.example .env.docker
    echo "⚠️  Please edit .env.docker with your Google Cloud configuration"
fi

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker is available"
    docker_available=true
else
    echo "⚠️  Docker not found - Docker features will not be available"
    docker_available=false
fi

# Check Google Cloud CLI
if command -v gcloud &> /dev/null; then
    echo "✅ Google Cloud CLI is available"
    gcloud_available=true
else
    echo "⚠️  Google Cloud CLI not found - please install for cloud deployment"
    gcloud_available=false
fi

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔧 Configure your environment:"
echo "   - Edit dataops/.env with your Google Cloud settings"
echo "   - Edit .env.docker for Docker deployment"
echo ""
echo "2. 🏗️ Deploy infrastructure (if needed):"
echo "   cd infra/"
echo "   terraform init"
echo "   terraform apply"
echo ""
echo "3. 🤖 Deploy the agent:"
echo "   cd agent-deployment/"
echo "   python deploy.py"
echo ""
echo "4. 🚀 Run the application:"
echo "   Local:  ./run_streamlit.sh"
if [ "$docker_available" = true ]; then
echo "   Docker: ./run_docker.sh"
fi
echo ""
echo "📖 For detailed instructions, see:"
echo "   - README.md for overview"
echo "   - DEVELOPERS_GUIDE.md for comprehensive guide"
echo ""
echo "🌐 The app will be available at http://localhost:8501"