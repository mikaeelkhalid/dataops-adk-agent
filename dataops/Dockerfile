FROM python:3.12-slim

WORKDIR /app

# Install uv
RUN apt-get update && apt-get install -y curl build-essential && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock ./
RUN /root/.local/bin/uv sync --frozen --no-cache

COPY dataops-agent /app/dataops-agent

ENV PORT=8080
EXPOSE 8080

CMD ["uvicorn", "dataops-agent.app:app", "--host", "0.0.0.0", "--port", "8080"]
