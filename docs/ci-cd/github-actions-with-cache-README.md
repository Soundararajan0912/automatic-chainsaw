# GitHub Actions Docker Cache Workflow

This repository contains reusable GitHub Actions workflows that build Docker images with Docker Buildx while leveraging GitHub's cache backend to shorten build times. It also explains how to persist package-manager data (pip and npm) when those commands run inside Docker layers.

---

## Workflow files

Copy whichever workflow suits your environment:

- `docker-cache-build.yml`: parametrized for self-hosted or custom runners (set the `runner_label` input).
- `docker-cache-build-hosted.yml`: pinned to `ubuntu-latest`, ideal when you want hosted runners with caching enabled out of the box.

Both workflows expose dispatch inputs for branch/context/Dockerfile/platform.

### Key environment variables / inputs
| Name | Type | Purpose | Default |
|------|------|---------|---------|
| `branch` | input | Git ref checked out for the build | `main` |
| `runner_label` | input (self-hosted workflow only) | Runner label (set to `self-hosted` for your runner) | `ubuntu-latest` |
| `build_context` | input/env | Build context passed to Docker | `.` |
| `dockerfile` | input/env | Dockerfile path inside the repo | `./Dockerfile` |
| `platform` | input/env | Platform string for Buildx | `linux/amd64` |
| `CACHE_SCOPE` | env | Cache namespace shared across runs | `${{ github.repository }}` |

You can override the inputs every time you run the workflow without touching the YAML. `CACHE_SCOPE` is set once so cached layers remain reusable between runs.

---

## How caching works

1. **BuildKit & Buildx**: The workflow enables Docker Buildx, which unlocks BuildKit features such as inline cache metadata and cache exports.
2. **GitHub Actions cache backend**: `docker/build-push-action@v5` is configured with `cache-to: type=gha` and `cache-from: type=gha`. GitHub automatically stores intermediate layers keyed by repository and rehydrates them in the next run.
3. **No registry login required**: The workflow intentionally skips registry authentication and does not push the resulting image. This keeps the sample minimal for cache testing. If you eventually want to push, add a login step and set `push: true`.
4. **Bring-your-own project**: The workflow now builds the Dockerfile that already lives in your repository. No sample code is cloned; you simply point to the Dockerfile/ context through the dispatch inputs (defaults cover the common case where both live at the repo root).

Because Docker layer hashes account for file contents, only changed layers are rebuilt. Keep dependency declarations (e.g., `requirements.txt`, `package-lock.json`) in their own layer to maximize reuse.

---

## pip and npm caching inside Docker

Running `pip install` or `npm install` inside Docker relies on the same layer caching as the rest of the build. For even better reuse you can opt into BuildKit cache mounts:

### Dockerfile snippet for pip
```dockerfile
# syntax=docker/dockerfile:1.6
FROM python:3.12-slim AS app

WORKDIR /app
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
```
- `--mount=type=cache` reuses pip's download cache between builds (tied to your BuildKit cache backend—GitHub Actions in this case).
- Keep `requirements.txt` copied before application code so that the layer reuses the cache unless dependencies change.

### Dockerfile snippet for npm / node
```dockerfile
# syntax=docker/dockerfile:1.6
FROM node:22-alpine AS web

WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline
```
- `npm ci` benefits from the cached `~/.npm` directory, reducing download time.
- Like pip, ensure dependency manifests are copied first to preserve the layer.

> **Note:** Cache mounts require BuildKit. The workflow already uses Buildx (which enables BuildKit by default on GitHub runners), so the same cache backend that handles Docker layers also stores pip/npm cache data.

If you cannot modify the Dockerfile, you still gain basic caching because Docker layers are reused whenever `requirements.txt` or `package-lock.json` do not change. The BuildKit cache mount simply reduces network traffic and speeds up rebuilds when dependency files do change.

---

## Using the workflow

1. Add (or copy) the workflow file to `.github/workflows/` in your repository.
2. Open **Actions → docker-cache-build → Run workflow**.
3. Provide the workflow inputs:
    - `branch`: the ref to check out (e.g., `main`).
    - `runner_label` (self-hosted workflow only): use `self-hosted` or your custom label. Omit for the hosted workflow.
    - `build_context` and `dockerfile`: adjust only if your Dockerfile lives outside the repo root.
    - `platform`: keep `linux/amd64` unless your runner targets something else.
4. Trigger the run. Re-run the workflow with the same inputs to observe cache hits (`Using cache` entries in the build logs).

### Self-hosted runners & caching
- The `type=gha` cache driver works on self-hosted runners as long as they can reach GitHub’s cache service (standard setup for GitHub Enterprise Cloud). No extra configuration is needed beyond using runner version 2.298.2 or newer.
- Ensure your runner has Docker + Buildx available. Linux runners usually just need the Docker engine installed; Buildx ships with modern Docker versions.
- For multi-arch builds, keep in mind that self-hosted runners typically only build for their native architecture unless QEMU emulation is configured.

---

## Troubleshooting tips

- **Cache misses every run**: Ensure `CACHE_SCOPE` stays constant and that you rebuild with the same Dockerfile/context. Clearing runner workspaces between jobs is fine; the cache lives in GitHub’s backend.
- **Build fails on registry login**: Replace `REGISTRY`, `username`, and `password` inputs with the credentials for your registry of choice. For AWS ECR or Azure ACR, swap in the appropriate login action before the build step.
- **pip/npm cache not used**: Confirm the Dockerfile uses BuildKit cache mounts and that the workflow is using Buildx. Also ensure the `# syntax=docker/dockerfile:1.6` directive appears at the top of the Dockerfile to unlock `RUN --mount` syntax.

This setup keeps your CI minutes low while ensuring iterative Docker builds remain fast, even when your build uses language-specific package installers inside the image.
