# Multi-stage Dockerfile for Python services using UV (Ultra-fast package installer)
# UV is 10-100x faster than pip and provides better dependency resolution
# Documentation: https://github.com/astral-sh/uv

# Stage 1: Builder - Install dependencies using UV
FROM python:3.11-slim AS builder

# Install UV from official image (ultra-fast Python package installer)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Accept build arguments for private package authentication
# These work the same way as the traditional pip Dockerfile
ARG PIP_INDEX_URL=""
ARG PIP_EXTRA_INDEX_URL="https://pypi.org/simple"
ARG PIP_TOKEN=""
ARG PIP_TRUSTED_HOST=""

# UV environment configuration
# UV respects pip environment variables but also has its own
ENV UV_INDEX_URL=${PIP_INDEX_URL}
ENV UV_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}
ENV UV_TRUSTED_HOST=${PIP_TRUSTED_HOST}

# Install build dependencies (if needed for packages with C extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies with UV
# UV automatically handles authentication when index URLs contain tokens
# --system: Install to system Python (not a virtual environment)
# --no-cache: Don't cache downloads (reduces image size)
RUN if [ -n "$PIP_TOKEN" ]; then \
      export UV_INDEX_URL="https://token:${PIP_TOKEN}@${PIP_INDEX_URL#https://}"; \
    fi && \
    uv pip install --system --no-cache -r requirements.txt

# Copy application code
COPY . .

# Stage 2: Runtime - Minimal production image
FROM python:3.11-slim

# Create non-root user for security
RUN adduser --disabled-password --no-create-home --gecos "" appuser

WORKDIR /app

# Copy installed packages and application from builder stage
# UV installs to system site-packages by default with --system flag
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
