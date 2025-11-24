# Example: Complete Setup with Private Packages

This example demonstrates a complete setup for a Flask application using both public and private packages.

## Files

### 1. requirements.txt
```txt
# ============================================
# PUBLIC PACKAGES (from PyPI)
# ============================================
flask==2.3.0
flask-cors==4.0.0
requests==2.31.0
python-dotenv==1.0.0
gunicorn==21.2.0
sqlalchemy==2.0.23

# ============================================
# PRIVATE PACKAGES (from ACR)
# ============================================
# These will be fetched from your ACR when you provide credentials
company-auth-lib==1.0.0
internal-api-client==2.1.5
shared-utilities==3.0.0
```

### 2. app.py
```python
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Dockerized Flask!',
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
```

### 3. Dockerfile
```dockerfile
# Copy from the template - already configured!
# No changes needed for basic usage
```

### 4. .dockerignore
```
# Copy from the template
```

### 5. .gitignore
```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
*.egg-info/

# Environment variables
.env
.env.local
*.token

# IDE
.vscode/
.idea/
*.swp
*.swo

# Docker
.dockerignore

# Credentials
pip.conf
.netrc
```

## Build and Run

### Option 1: Without Private Packages (Public Only)

If your requirements.txt only has public packages:

```powershell
# Build
docker build -t flask-service:latest .

# Run
docker run -p 5000:5000 flask-service:latest

# Test
Invoke-WebRequest http://localhost:5000
```

### Option 2: With Private Packages from ACR

#### Step 1: Get ACR Credentials

```powershell
# Set your ACR name
$ACR_NAME = "mycompanyregistry"

# Create a token (do this once)
az acr token create `
  --name pip-build-token `
  --registry $ACR_NAME `
  --scope-map _repositories_pull `
  --expiration-in-days 30

# Get the token password
$TOKEN = az acr token credential generate `
  --name pip-build-token `
  --registry $ACR_NAME `
  --password1 `
  --query "passwords[0].value" `
  --output tsv

# Save for later use (optional)
$TOKEN | Out-File -FilePath .\.token -NoNewline
```

#### Step 2: Build with Private Packages

```powershell
# Load token (if saved)
$ACR_TOKEN = Get-Content .\.token

# Build
docker build `
  --build-arg PIP_INDEX_URL="https://${ACR_NAME}.azurecr.io/pypi/simple/" `
  --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
  --build-arg PIP_TOKEN="${ACR_TOKEN}" `
  --build-arg PIP_TRUSTED_HOST="${ACR_NAME}.azurecr.io" `
  -t flask-service:latest .
```

#### Step 3: Run and Test

```powershell
# Run the container
docker run -d -p 5000:5000 --name flask-app flask-service:latest

# Test the endpoints
Invoke-WebRequest http://localhost:5000
Invoke-WebRequest http://localhost:5000/health

# View logs
docker logs flask-app

# Stop and remove
docker stop flask-app
docker rm flask-app
```

### Option 3: Using Environment Variables

Create a build script for convenience:

**build.ps1:**
```powershell
param(
    [Parameter(Mandatory=$false)]
    [string]$ACRName = $env:ACR_NAME,
    
    [Parameter(Mandatory=$false)]
    [string]$ACRToken = $env:ACR_TOKEN,
    
    [Parameter(Mandatory=$true)]
    [string]$ImageName,
    
    [Parameter(Mandatory=$false)]
    [string]$Tag = "latest"
)

$fullImageName = "${ImageName}:${Tag}"

if ($ACRName -and $ACRToken) {
    Write-Host "Building with private package support from $ACRName..."
    docker build `
        --build-arg PIP_INDEX_URL="https://${ACRName}.azurecr.io/pypi/simple/" `
        --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
        --build-arg PIP_TOKEN="${ACRToken}" `
        --build-arg PIP_TRUSTED_HOST="${ACRName}.azurecr.io" `
        -t $fullImageName `
        .
} else {
    Write-Host "Building with public packages only..."
    docker build -t $fullImageName .
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Successfully built $fullImageName"
} else {
    Write-Host "❌ Build failed"
    exit 1
}
```

**Usage:**
```powershell
# Set environment variables once
$env:ACR_NAME = "mycompanyregistry"
$env:ACR_TOKEN = "your-token-here"

# Build using the script
.\build.ps1 -ImageName flask-service -Tag v1.0.0
```

## Verification

### Check Installed Packages

```powershell
# List all installed packages in the container
docker run --rm flask-service:latest pip list

# Check for specific private package
docker run --rm flask-service:latest pip show company-auth-lib

# Verify package sources
docker run --rm flask-service:latest pip list -v
```

### Inspect Image Size

```powershell
# Check image size
docker images flask-service:latest

# View image layers
docker history flask-service:latest

# Expected size: ~200-300MB for Python 3.11 slim with typical dependencies
```

### Security Scan

```powershell
# Scan for vulnerabilities
docker scan flask-service:latest

# Or using Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image flask-service:latest
```
