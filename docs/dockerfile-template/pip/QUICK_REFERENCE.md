# Quick Reference Guide

## 🚀 Quick Start Commands

### Basic Build (Public Packages Only)
```powershell
docker build -t your-service:latest .
```

### Build with Private Packages (ACR)
```powershell
# Set your variables
$ACR_NAME = "yourregistryname"
$ACR_TOKEN = "your-token-here"

# Build with private package support
docker build `
  --build-arg PIP_INDEX_URL="https://${ACR_NAME}.azurecr.io/pypi/simple/" `
  --build-arg PIP_EXTRA_INDEX_URL="https://pypi.org/simple" `
  --build-arg PIP_TOKEN="${ACR_TOKEN}" `
  --build-arg PIP_TRUSTED_HOST="${ACR_NAME}.azurecr.io" `
  -t your-service:latest .
```

### Run Container
```powershell
docker run -p 5000:5000 your-service:latest
```

## 📦 Package Resolution Priority

| Configuration | Primary (Checked First) | Fallback (Checked Second) |
|---------------|-------------------------|---------------------------|
| **Recommended** | ACR (private) | PyPI (public) |
| Alternative | PyPI (public) | ACR (private) |
| Air-gapped | ACR only | None |

## 🔐 Getting ACR Token

```powershell
# Quick method - create token
az acr token create `
  --name pip-build-token `
  --registry <acr-name> `
  --scope-map _repositories_pull `
  --expiration-in-days 30

# Get password
az acr token credential generate `
  --name pip-build-token `
  --registry <acr-name> `
  --password1
```

## 📝 Requirements.txt Examples

### Mixed Public and Private Packages
```txt
# Public packages (from PyPI)
flask==2.3.0
requests==2.31.0

# Private packages (from ACR)
your-private-package==1.0.0
internal-lib==2.1.0

# Explicit source (optional)
private-utils @ https://yourregistry.azurecr.io/pypi/simple/private-utils/
```

## 🛠️ Common Customizations

### Change Python Version
```dockerfile
FROM python:3.12-slim AS builder
# ...
FROM python:3.12-slim
```

### Change Port
```dockerfile
EXPOSE 8080
```
```powershell
docker run -p 8080:8080 your-service:latest
```

### Change Entry Point
```dockerfile
# Flask with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]

# FastAPI with Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## ⚠️ Common Issues

| Issue | Solution |
|-------|----------|
| Package not found | Check ACR token and package availability |
| SSL Certificate error | Add `--build-arg PIP_TRUSTED_HOST=<acr-name>.azurecr.io` |
| 401 Unauthorized | Regenerate token or check permissions |
| Permission denied | Already handled - uses non-root user |
| Large image size | Check .dockerignore, use --no-cache-dir (already in template) |

## 🔒 Security Checklist

- [ ] Never commit tokens to git (add to .gitignore)
- [ ] Use short-lived tokens (7-30 days)
- [ ] Store tokens in Azure Key Vault or GitHub Secrets
- [ ] Rotate tokens regularly
- [ ] Use least-privilege access (pull-only tokens)
- [ ] Don't use admin credentials in production
- [ ] Scan images with `docker scan your-service:latest`

## 📂 File Structure

```
your-service/
├── app.py              # Your application
├── requirements.txt    # Dependencies
├── Dockerfile          # Copy from template
├── .dockerignore       # Copy from template
└── .gitignore          # Add: .env, *.token, pip.conf
```


---

**Template Version:** 2.0  
**Last Updated:** November 24, 2025
