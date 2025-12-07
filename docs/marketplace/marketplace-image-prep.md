# Cloud Marketplace Image Publishing Checklist

Use this guide when preparing hardened VM or container images for cloud marketplaces (Azure Marketplace, AWS Marketplace, GCP Marketplace). It captures prerequisites, operational readiness, and automation workflows that partners typically expect.

## 1. Image Hardening & Build Hygiene
- **Base OS hardening**: Apply CIS/STIG controls, disable unused services, enforce minimal users/groups, lock down SSH/RDP.
- **Hardened Docker image**: Multi-stage Dockerfile that copies only compiled artifacts, drops root privileges, and sets restrictive file permissions.
- **Vulnerability remediation**: Scan container/VM packages with Trivy, Microsoft Defender, or AWS Inspector; patch critical/high CVEs before publishing.
- **Minimal footprint**: Prefer distroless/alpine base layers, prune build dependencies, compress artifacts to keep image size low and speed up downloads.
- **Cold-start optimization**: Pre-generate caches, JIT bundles, or native images so the app starts within marketplace SLAs; disable lazy asset downloads that trigger long first-boot waits.
- **Auto-remediation hooks**: Bake in scripts/service units that detect and fix known transient issues (e.g., regenerate TLS certs, clean stale locks) on boot.

## 2. Deployment & Automation
- **Single-command installer**: Provide `/opt/app/setup.sh` (or similar) that configures dependencies, handles idempotency, and emits health status.
- **Server-level backup plan**: Document how customers snapshot the VM, back up app data, and restore; integrate with cloud backup agents where possible.
- **Host OS requirements**: Specify supported distributions/SKUs for BYOS scenarios; include instructions for enabling disk encryption and secure boot.
- **Reverse engineering countermeasures**: Strip debug symbols, obfuscate sensitive binaries, enable license checks, and ensure runtime secrets are fetched from customer-managed vaults.
- **Headless debugging capability**: Ship support scripts/diagnostics (`/opt/app/support/*`) that gather logs, metrics, and config bundles without requiring vendor login to the customer machine.

## 3. Upgrade & Lifecycle
- **Dual upgrade paths**: Describe how to perform app-only upgrades (in-place container/VM package), OS-level upgrades, and monthly security patching cycles.
- **Data migration strategy**: Include migration scripts that transform schema/state between versions; provide rollback/restore scripts to revert if needed.
- **Versioning & support policy**: Publish supported versions, EOL timelines, and cadence for major/minor updates. Communicate overlap periods where two versions receive fixes.

## 4. Data & Database Planning
- **Database placement**: Clarify whether the app bundles a database on the same VM/container or expects an external PaaS DB (Azure SQL, RDS, Cloud SQL). Provide guidance for both.
- **Migration kits**: Provide tooling to export/import data when moving between bundled DB and managed DB instances.

## 5. Security & Access Control
- **Application login mechanism**: Document identity providers (local accounts, Azure AD, SAML, OIDC) and initial admin credential rotation steps.
- **Block reverse tunneling**: Disable default outbound management tunnels; require customers to configure Bastion/SSM for access.
- **Logging without vendor access**: Provide CLI commands or scripts that collect support bundles customers can send without granting shell access.

## 6. Monitoring & Housekeeping
- **Built-in telemetry**: Emit structured logs to stdout/syslog and integrate with Azure Monitor/CloudWatch/Stackdriver using agents.
- **Health probes**: Expose `/healthz` or equivalent endpoints for load balancers and include documentation.
- **Housekeeping automation**: Cron/systemd timers that rotate logs, purge temp data, and address previously observed reliability issues.
- **Alerting guidance**: Recommend default metrics/alerts (CPU, memory, response time, error rate) and thresholds.

## 7. Pipeline & Publishing Automation
- **CI/CD pipeline**: Build Docker/VM images via GitHub Actions, Azure Pipelines, or Jenkins with steps for lint, unit tests, SAST, dependency scanning, image signing, and artifact retention.
- **Marketplace packaging**: Automate creation of marketplace manifests (Azure managed application, AWS AMI copy, GCP image) and run validation scripts before submission.
- **Promotion flow**: Use staged environments (dev → QA → prod) and sign artifacts so the published image is traceable.
- **Release documentation**: Generate release notes, security advisories, and upgrade guides automatically from commits.


