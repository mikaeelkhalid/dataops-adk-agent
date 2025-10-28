FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install Python dependencies with pip so console scripts (streamlit, uvicorn) are installed into /usr/local/bin
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
      "ag-ui-adk>=0.3.1" \
      "dependency>=0.0.3" \
      "fastapi[standard]>=0.120.0" \
      "google-adk>=1.17.0" \
      "google-auth>=2.41.1" \
      "google-cloud-aiplatform>=1.122.0" \
      "jinja2>=3.1.6" \
      "pydantic>=2.12.3" \
      "python-dotenv>=1.2.1" \
      "streamlit>=1.50.0" \
      "uvicorn[standard]>=0.38.0"

# Copy application code
COPY app/ ./app/
COPY dataops/ ./dataops/

# Create a non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose Streamlit port
EXPOSE 8501

# Health check (curl is installed above)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Set environment variables for Streamlit
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0
ENV STREAMLIT_SERVER_HEADLESS=true
ENV STREAMLIT_BROWSER_GATHER_USAGE_STATS=false

# Run the Streamlit app directly (console script installed by pip)
CMD ["streamlit", "run", "app/app.py", "--server.port=8501", "--server.address=0.0.0.0"]