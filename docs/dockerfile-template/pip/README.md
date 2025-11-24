# Python Service Dockerfile Template

This repository contains a standardized Dockerfile and .dockerignore template for Python services. Use this template to ensure consistent, secure, and optimized Docker images across all Python services in your projects.

## 📋 Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [File Structure](#file-structure)
- [Dockerfile Explained](#dockerfile-explained)
- [Dockerignore Explained](#dockerignore-explained)
- [Private Pip Packages (ACR)](#private-pip-packages-acr)
- [Package Resolution Order](#package-resolution-order)
- [Customization Guide](#customization-guide)
- [Best Practices](#best-practices)
- [Common Issues](#common-issues)

## ✨ Features

- **Multi-stage build**: Reduces final image size by separating build dependencies from runtime
- **Security-focused**: Runs as non-root user with minimal permissions
- **Optimized caching**: Leverages Docker layer caching for faster builds
- **Production-ready**: Uses slim Python base image with only necessary dependencies
- **Clean builds**: Includes comprehensive .dockerignore to exclude unnecessary files
- **Private package support**: Secure authentication for private pip packages from ACR

## 🚀 Quick Start

### Prerequisites

- Docker installed on your machine
- Python service with a `requirements.txt` file
- Application entry point (e.g., `app.py`)
- (Optional) Azure Container Registry credentials for private packages

### Setup Instructions

1. **Copy the template files to your Python service repository:**
   ```powershell
   Copy-Item Dockerfile <your-service-directory>\
   Copy-Item .dockerignore <your-service-directory>\
   ```

2. **Customize the Dockerfile** (if needed):
   - Update Python version if required
   - Change the exposed port (default: 5000)
   - Modify the CMD to match your application entry point

3. **Build your Docker image:**
   
   **Without private packages:**
   ```powershell
   docker build -t your-service-name:latest .
   ```
   
   **With private packages from ACR:**
   ```powershell
   docker build `
     --build-arg PIP_INDEX_URL="https://<acr-name>.azurecr.io/pypi/simple/" `
     --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
     --build-arg PIP_TOKEN="<your-acr-token>" `
     -t your-service-name:latest .
   ```

4. **Run your container:**
   ```powershell
   docker run -p 5000:5000 your-service-name:latest
   ```

## 📁 File Structure

Your Python service should have at minimum:

```
your-service/
├── app.py              # Your application entry point
├── requirements.txt    # Python dependencies (public & private)
├── Dockerfile          # This template
└── .dockerignore       # Files to exclude from Docker context
```

## 🔍 Dockerfile Explained

### Updated Dockerfile with Private Package Support

```dockerfile
# Stage 1: Builder - Install dependencies
FROM python:3.11-slim AS builder

# Accept build arguments for private package authentication
ARG PIP_INDEX_URL=""
ARG PIP_EXTRA_INDEX_URL="https://pypi.org/simple"
ARG PIP_TOKEN=""
ARG PIP_TRUSTED_HOST=""

# Set pip configuration as environment variables
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
ENV PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}
ENV PIP_TRUSTED_HOST=${PIP_TRUSTED_HOST}

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies with authentication
RUN if [ -n "$PIP_TOKEN" ]; then \
      pip config set global.index-url "https://token:${PIP_TOKEN}@${PIP_INDEX_URL#https://}"; \
    fi && \
    pip install --user --no-cache-dir -r requirements.txt && \
    pip config unset global.index-url || true

# Copy application code
COPY . .

# Stage 2: Runtime - Minimal production image
FROM python:3.11-slim

# Create non-root user
RUN adduser --disabled-password --no-create-home --gecos "" appuser

WORKDIR /app

# Copy installed packages and application from builder
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
```

### Stage 1: Builder (Updated)

```dockerfile
ARG PIP_INDEX_URL=""
ARG PIP_EXTRA_INDEX_URL="https://pypi.org/simple"
ARG PIP_TOKEN=""
ARG PIP_TRUSTED_HOST=""
```
- Declares build arguments for pip authentication
- `PIP_INDEX_URL`: Primary package index (your ACR) - checked **FIRST**
- `PIP_EXTRA_INDEX_URL`: Fallback index (public PyPI) - checked **SECOND**
- `PIP_TOKEN`: Authentication token for private registry
- `PIP_TRUSTED_HOST`: Optional, for handling SSL/TLS

```dockerfile
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
ENV PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}
```
- Sets environment variables for pip configuration
- Only exists in builder stage, not in final image

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
```
- Installs build tools needed for compiling Python packages with C extensions
- Cleans up apt cache to reduce layer size

```dockerfile
COPY requirements.txt .
```
- Copies only requirements.txt first for better cache utilization
- Docker caches this layer - rebuilds only if requirements.txt changes

```dockerfile
RUN if [ -n "$PIP_TOKEN" ]; then \
      pip config set global.index-url "https://token:${PIP_TOKEN}@${PIP_INDEX_URL#https://}"; \
    fi && \
    pip install --user --no-cache-dir -r requirements.txt && \
    pip config unset global.index-url || true
```
- Conditionally configures pip authentication if token is provided
- Installs dependencies from both private (ACR) and public (PyPI) indexes
- `--no-cache-dir` prevents pip from storing cache, reducing image size
- **Security:** Clears pip configuration after installation to prevent token leakage

```dockerfile
COPY . .
```
- Copies your application code after dependencies are installed
- This allows Docker to cache the dependency layer when code changes

### Stage 2: Runtime (Unchanged)

```dockerfile
FROM python:3.11-slim
```
- Fresh slim image for runtime (without build tools)
- Keeps final image size minimal
- **Important:** No credentials or tokens in this stage

```dockerfile
RUN adduser --disabled-password --no-create-home --gecos "" appuser
```
- Creates a non-root user for security
- Containers should never run as root in production

```dockerfile
COPY --from=builder /app /app
COPY --from=builder /root/.local /root/.local
```
- Copies application code and installed packages from builder stage
- Only runtime artifacts, not build tools or credentials

```dockerfile
ENV PATH=/root/.local/bin:$PATH
```
- Sets PATH to include user-installed packages
- Ensures Python can find installed dependencies

```dockerfile
USER appuser
```
- Switches to non-root user for running the application
- Enhanced security posture

```dockerfile
EXPOSE 5000
CMD ["python", "app.py"]
```
- Documents which port the service uses
- Defines the command to start your application

## 🚫 Dockerignore Explained

The `.dockerignore` file excludes files from the Docker build context:

| Pattern | Purpose |
|---------|---------|
| `.git` | Version control files (not needed in container) |
| `.env` | Environment variables (should be passed at runtime) |
| `*.pyc`, `__pycache__` | Python bytecode (regenerated in container) |
| `*.pytest_cache` | Test cache files |
| `Dockerfile`, `.dockerignore` | Docker files (already used by build) |
| `*.md` | Documentation files |
| `tests/`, `docs/` | Development-only directories |
| `.vscode/`, `.idea/` | IDE configuration files |

**Benefits:**
- Faster builds (smaller context transferred to Docker daemon)
- Smaller final images
- Avoids accidentally including sensitive files

## � Private Pip Packages (ACR)

### Overview

This template supports installing private Python packages from Azure Container Registry (ACR) using secure token-based authentication during build time.

### Prerequisites

1. **ACR Instance** with Python package feed enabled
2. **Access Token** or Service Principal credentials
3. **Private packages** published to ACR

### Getting ACR Credentials

#### Option 1: Generate ACR Token (Recommended)

```powershell
# Create a token with repository-scoped permissions
az acr token create `
  --name pip-build-token `
  --registry <acr-name> `
  --scope-map _repositories_pull `
  --expiration-in-days 30

# Get the token password
az acr token credential generate `
  --name pip-build-token `
  --registry <acr-name> `
  --password1
```

#### Option 2: Use Service Principal

```powershell
# Create service principal with AcrPull role
az ad sp create-for-rbac `
  --name http://<acr-name>-pip-reader `
  --scopes /subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.ContainerRegistry/registries/<acr-name> `
  --role AcrPull

# Use appId as username and password as token
```

#### Option 3: Use ACR Admin Credentials (Not Recommended for Production)

```powershell
az acr credential show --name <acr-name>
```

### Requirements.txt Format

Your `requirements.txt` can include both public and private packages:

```txt
# Public packages from PyPI
flask==2.3.0
requests==2.31.0
python-dotenv==1.0.0

# Private packages from ACR
# These will be automatically fetched from ACR when PIP_INDEX_URL is configured
your-private-package==1.0.0
another-private-lib==2.1.5

# You can also explicitly specify the registry (optional)
private-utils @ https://<acr-name>.azurecr.io/pypi/simple/private-utils/
```

### Build Commands

#### Local Development Build

```powershell
# Set your ACR details
$ACR_NAME = "yourregistryname"
$ACR_TOKEN = "your-token-here"

# Build with private package support
docker build `
  --build-arg PIP_INDEX_URL="https://${ACR_NAME}.azurecr.io/pypi/simple/" `
  --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
  --build-arg PIP_TOKEN="${ACR_TOKEN}" `
  --build-arg PIP_TRUSTED_HOST="${ACR_NAME}.azurecr.io" `
  -t your-service-name:latest .
```

#### Using Environment Variables

```powershell
# Set environment variables
$env:ACR_NAME = "yourregistryname"
$env:ACR_TOKEN = "your-token-here"

# Build using environment variables
docker build `
  --build-arg PIP_INDEX_URL="https://$env:ACR_NAME.azurecr.io/pypi/simple/" `
  --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
  --build-arg PIP_TOKEN="$env:ACR_TOKEN" `
  --build-arg PIP_TRUSTED_HOST="$env:ACR_NAME.azurecr.io" `
  -t your-service-name:latest .
```

#### Build Without Private Packages

```powershell
# Standard build (only public PyPI packages)
docker build -t your-service-name:latest .
```


### Security Best Practices

#### ✅ DO:

1. **Store tokens in secret management systems:**
   - Azure Key Vault
   - GitHub Secrets
   - GitLab CI/CD Variables
   - AWS Secrets Manager

2. **Use short-lived tokens:**
   ```powershell
   # Create token with 7-day expiration
   az acr token create --expiration-in-days 7
   ```

3. **Use least-privilege access:**
   - Create tokens with only pull permissions
   - Use repository-scoped tokens

4. **Rotate tokens regularly:**
   ```powershell
   az acr token credential generate --password1
   ```

5. **Use BuildKit secrets (advanced):**
   ```dockerfile
   # syntax=docker/dockerfile:1
   RUN --mount=type=secret,id=pip_token \
       PIP_TOKEN=$(cat /run/secrets/pip_token) && \
       pip install -r requirements.txt
   ```

#### ❌ DON'T:

1. **Never commit tokens to git:**
   ```powershell
   # Add to .gitignore
   echo ".env" >> .gitignore
   echo "*.token" >> .gitignore
   ```

2. **Don't use admin credentials in production**

3. **Don't hardcode credentials in Dockerfile**

4. **Don't pass secrets as environment variables in final image:**
   ```dockerfile
   # ❌ BAD - Token in final image
   ENV PIP_TOKEN=secret123
   
   # ✅ GOOD - Token only in builder stage
   ARG PIP_TOKEN
   ```

5. **Don't log build arguments:**
   ```powershell
   # Tokens will be visible in build output
   docker build --progress=plain  # Avoid in CI/CD
   ```

### Troubleshooting Private Packages

#### Issue: "Could not find a version that satisfies the requirement"

**Cause:** Authentication failed or package not found in ACR

**Solutions:**
```powershell
# Verify token is valid
$TOKEN = "your-token"
$ACR_NAME = "yourregistryname"

Invoke-WebRequest -Uri "https://${ACR_NAME}.azurecr.io/pypi/simple/" `
  -Headers @{Authorization="Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("token:${TOKEN}")))"}

# Check if package exists in ACR
az acr repository list --name $ACR_NAME --output table
```

#### Issue: "SSL: CERTIFICATE_VERIFY_FAILED"

**Cause:** SSL verification issues with ACR

**Solution:**
```powershell
docker build `
  --build-arg PIP_TRUSTED_HOST="yourregistryname.azurecr.io" `
  ...
```

#### Issue: "401 Unauthorized"

**Cause:** Token expired or invalid

**Solutions:**
- Regenerate token
- Verify token has pull permissions
- Check token hasn't expired

## 📦 Package Resolution Order

### How Pip Searches for Packages

When using both private (ACR) and public (PyPI) registries:

```
PIP_INDEX_URL (Primary)        → ACR Private Registry (checked FIRST)
     ↓ (if not found)
PIP_EXTRA_INDEX_URL (Fallback) → Public PyPI (checked SECOND)
```

### Package Installation Logic

| Scenario | ACR Has Package? | PyPI Has Package? | Installs From |
|----------|------------------|-------------------|---------------|
| Private package | ✅ Yes | ❌ No | ACR |
| Public package | ❌ No | ✅ Yes | PyPI |
| Both have it | ✅ Yes | ✅ Yes | **ACR (primary wins)** |
| Package mirrored in ACR | ✅ Yes (mirrored) | ✅ Yes | **ACR (faster, cached)** |

### Example Build Scenarios

#### Default Configuration (ACR First, PyPI Second)

```powershell
docker build `
  --build-arg PIP_INDEX_URL="https://yourregistry.azurecr.io/pypi/simple/" `
  --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
  --build-arg PIP_TOKEN="your-token" `
  -t your-service:latest .
```

**What happens:**
```txt
# requirements.txt
flask==2.3.0              # Checks ACR first, falls back to PyPI
your-private-lib==1.0.0   # Only in ACR, installs from ACR
requests==2.31.0          # Checks ACR first, falls back to PyPI
```

#### Public First, Private Second (Alternative)

```powershell
docker build `
  --build-arg PIP_INDEX_URL="https://pypi.org/simple" `
  --build-arg PIP_EXTRA_INDEX_URL="https://yourregistry.azurecr.io/pypi/simple/" `
  --build-arg PIP_TOKEN="your-token" `
  -t your-service:latest .
```

**What happens:**
```txt
# requirements.txt
flask==2.3.0              # Installs from PyPI (primary)
your-private-lib==1.0.0   # Not in PyPI, falls back to ACR
requests==2.31.0          # Installs from PyPI (primary)
```

#### Only Private Registry (No Public Access)

```powershell
docker build `
  --build-arg PIP_INDEX_URL="https://yourregistry.azurecr.io/pypi/simple/" `
  --build-arg PIP_TOKEN="your-token" `
  -t your-service:latest .
```

**What happens:**
- Only searches ACR
- All packages must be in ACR (including public packages you've mirrored)
- Build fails if package not found in ACR

### Explicit Package Sources

For maximum control, specify exact sources in requirements.txt:

```txt
# requirements.txt

# ============================================
# PUBLIC PACKAGES (from PyPI)
# ============================================
flask==2.3.0
requests==2.31.0
sqlalchemy==2.0.0

# ============================================
# PRIVATE PACKAGES (from ACR)
# ============================================
# Method 1: Using @ syntax (recommended)
company-auth-lib==1.0.0 @ https://yourregistry.azurecr.io/pypi/simple/company-auth-lib/
internal-utils==2.1.0 @ https://yourregistry.azurecr.io/pypi/simple/internal-utils/

# Method 2: Will search configured indexes in order
your-private-package==1.0.0
```

### Best Practice Recommendations

1. **For Most Projects (Hybrid Approach):**
   ```powershell
   # ACR first for caching benefits, PyPI as fallback
   --build-arg PIP_INDEX_URL="https://yourregistry.azurecr.io/pypi/simple/"
   --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple"
   ```
   - ✅ Private packages from ACR
   - ✅ Public packages from ACR if mirrored (faster)
   - ✅ Public packages from PyPI if not in ACR
   - ✅ Better for air-gapped or high-security environments

2. **For Simple Projects (Public First):**
   ```powershell
   # PyPI first, ACR only for private packages
   --build-arg PIP_INDEX_URL="https://pypi.org/simple"
   --build-arg PIP_EXTRA_INDEX_URL="https://yourregistry.azurecr.io/pypi/simple/"
   ```
   - ✅ Ensures public packages always from official source
   - ✅ Only uses ACR for truly private packages
   - ✅ Simpler to understand and debug

3. **For High-Security/Air-Gapped Environments:**
   ```powershell
   # Only ACR, no internet access
   --build-arg PIP_INDEX_URL="https://yourregistry.azurecr.io/pypi/simple/"
   ```
   - ✅ Complete control over all packages
   - ✅ No external dependencies
   - ⚠️ Requires mirroring all public packages to ACR

## �🛠️ Customization Guide

### Change Python Version

Replace `3.11` with your desired version in both FROM statements:

```dockerfile
FROM python:3.12-slim AS builder
# ...
FROM python:3.12-slim
```

### Change Application Port

Update the EXPOSE directive and your run command:

```dockerfile
EXPOSE 8080
```

```powershell
docker run -p 8080:8080 your-service-name:latest
```

### Change Entry Point

Modify the CMD instruction to match your application:

```dockerfile
# For Flask with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]

# For FastAPI with Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# For Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

### Add System Dependencies

If your application needs additional system packages:

```dockerfile
# In the builder stage
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# In the runtime stage (if needed at runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*
```

### Add Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1
```

### Environment Variables

```dockerfile
# Add before CMD
ENV FLASK_APP=app.py \
    FLASK_ENV=production \
    PYTHONUNBUFFERED=1
```

## 📝 Best Practices

### 1. **Keep requirements.txt Updated**
   - Pin specific versions for reproducible builds
   - Example: `flask==2.3.0` instead of `flask`

### 2. **Use Multi-Stage Builds**
   - Already implemented in this template
   - Reduces final image size by 50-70%
   - **Critical for security**: Credentials only exist in builder stage

### 3. **Run as Non-Root User**
   - Already implemented in this template
   - Critical for security in production

### 4. **Minimize Layers**
   - Combine RUN commands with `&&`
   - Clean up in the same layer where files are created

### 5. **Use .dockerignore**
   - Already provided in this template
   - Customize for your specific needs

### 6. **Tag Your Images Properly**
   ```powershell
   docker build -t your-service:v1.0.0 .
   docker build -t your-service:latest .
   ```

### 7. **Environment-Specific Configuration**
   - Don't hardcode configuration in Dockerfile
   - Use environment variables or mounted config files
   ```powershell
   docker run -e DATABASE_URL=postgres://... your-service:latest
   ```

### 8. **Security Scanning**
   ```powershell
   docker scan your-service:latest
   ```

### 9. **Credential Management**
   - **Never** commit secrets to version control
   - Use secret management systems (Key Vault, etc.)
   - Rotate credentials regularly
   - Use build arguments for sensitive data

### 10. **Audit Build Arguments**
   ```powershell
   # View image history (build args are visible here)
   docker history your-service:latest
   
   # Build args don't persist in final image but are visible in metadata
   # This is why we clear pip config after installation
   ```

## 🔧 Common Issues

### Issue: "Permission denied" when running container

**Cause:** Non-root user doesn't have necessary permissions

**Solution:** Ensure directories are owned by appuser before switching users:
```dockerfile
RUN chown -R appuser:appuser /app
USER appuser
```

### Issue: Package installation fails in builder stage

**Cause:** Missing system dependencies for packages with C extensions

**Solution:** Add required system packages to builder stage:
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
```

### Issue: Application can't find installed packages

**Cause:** PATH not set correctly for user-installed packages

**Solution:** Already handled in template with:
```dockerfile
ENV PATH=/root/.local/bin:$PATH
```

### Issue: Large image size

**Solutions:**
- Ensure .dockerignore is working (check build context size)
- Use `--no-cache-dir` with pip (already in template)
- Remove unnecessary dependencies from requirements.txt
- Consider using alpine-based images (requires more setup)

### Issue: Slow builds

**Solutions:**
- Ensure requirements.txt is copied before application code
- Use BuildKit for better caching:
  ```powershell
  $env:DOCKER_BUILDKIT=1; docker build -t your-service .
  ```
- Check .dockerignore to exclude large directories

### Issue: Private packages fail to install

**See:** [Troubleshooting Private Packages](#troubleshooting-private-packages) section above

### Issue: Build arguments visible in image history

**Cause:** Docker stores metadata about build arguments

**Solution:** This is expected behavior. However:
- Credentials are cleared after use in the template
- They don't persist in the final image's filesystem
- They're only needed during build time
- Use secret mounts for even better security (Docker BuildKit)

## 📊 Example Build Output

Expected output when building with private packages:

```
[+] Building 52.3s (18/18) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/python:3.11-slim
 => [builder 1/7] FROM python:3.11-slim
 => [internal] load build context
 => [builder 2/7] RUN apt-get update && apt-get install...
 => [builder 3/7] WORKDIR /app
 => [builder 4/7] COPY requirements.txt .
 => [builder 5/7] RUN if [ -n "***" ]; then pip config set...     # Token masked
 => [builder 6/7] COPY . .
 => [stage-1 2/7] RUN adduser --disabled-password...
 => [stage-1 3/7] WORKDIR /app
 => [stage-1 4/7] COPY --from=builder /app /app
 => [stage-1 5/7] COPY --from=builder /root/.local...
 => [stage-1 6/7] RUN chown -R appuser:appuser /app
 => exporting to image
 => => exporting layers
 => => writing image sha256:abc123...
 => => naming to docker.io/library/your-service-name:latest
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Python Docker Best Practices](https://docs.docker.com/language/python/)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Azure Container Registry](https://docs.microsoft.com/azure/container-registry/)
- [ACR Python Package Support](https://docs.microsoft.com/azure/container-registry/container-registry-python-package)
- [Docker BuildKit Secrets](https://docs.docker.com/build/building/secrets/)

---

**Last Updated:** November 24, 2025  
**Template Version:** 2.0  

