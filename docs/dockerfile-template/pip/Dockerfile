# Stage 1: Builder - Install dependencies
FROM python:3.11-slim AS builder

# Accept build arguments for private package authentication
# PIP_INDEX_URL: Primary registry (checked FIRST) - your private ACR
# PIP_EXTRA_INDEX_URL: Fallback registry (checked SECOND) - public PyPI
ARG PIP_INDEX_URL=""
ARG PIP_EXTRA_INDEX_URL="https://pypi.org/simple"
ARG PIP_TOKEN=""
ARG PIP_TRUSTED_HOST=""

# Set pip configuration as environment variables for the build
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
ENV PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}
ENV PIP_TRUSTED_HOST=${PIP_TRUSTED_HOST}

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only dependency manifest for better caching
COPY requirements.txt .

# Install Python dependencies with authentication
# If PIP_TOKEN is provided, configure pip to use it
RUN if [ -n "$PIP_TOKEN" ]; then \
      pip config set global.index-url "https://token:${PIP_TOKEN}@${PIP_INDEX_URL#https://}"; \
    fi && \
    pip install --user --no-cache-dir -r requirements.txt && \
    # Clear pip configuration to avoid leaking credentials
    pip config unset global.index-url || true

# Copy the application code
COPY . .
# Stage 2: Runtime - Minimal production image
FROM python:3.11-slim

# Create non-root user for security
RUN adduser --disabled-password --no-create-home --gecos "" appuser

# Set work directory
WORKDIR /app

# Copy installed packages and application from builder stage
COPY --from=builder /app /app
COPY --from=builder /root/.local /root/.local

# Set PATH for user-installed packages
ENV PATH=/root/.local/bin:$PATH

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]