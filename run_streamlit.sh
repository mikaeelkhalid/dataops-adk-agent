#!/bin/bash

# DataOps Agent - Streamlit App Runner
echo "🚀 Starting DataOps GitHub Analysis Agent..."

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment not found. Please run 'uv sync' first."
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate

# Check if required environment variables are set
if [ ! -f "dataops/.env" ]; then
    echo "❌ Environment file not found at dataops/.env"
    echo "Please ensure your .env file exists with the following variables:"
    echo "  - GOOGLE_CLOUD_PROJECT"
    echo "  - GOOGLE_CLOUD_LOCATION" 
    echo "  - AGENT_ENGINE_ID"
    exit 1
fi

# Start Streamlit app
echo "🌐 Starting Streamlit app on http://localhost:8501"
echo "💡 Use Ctrl+C to stop the application"
echo ""

streamlit run app/app.py --server.port 8501 --server.address 0.0.0.0