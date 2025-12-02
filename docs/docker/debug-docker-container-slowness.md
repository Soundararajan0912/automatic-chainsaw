# Troubleshooting Slow Container Boot Times

Use this checklist whenever a container (regardless of base image) spends several minutes before becoming healthy after deployment.

## Quick triage flow

| Step | Question | Command / Signal |
| --- | --- | --- |
| 1 | Does the container start the expected process immediately? | `docker inspect <id> --format '{{.Path}} {{.Args}}'`
| 2 | Is the ENTRYPOINT script blocking on a long-running task? | Add `set -x`, ship logs to stdout/stderr |
| 3 | Are we waiting on package updates or runtime installs? | Search logs for `apt`, `dnf`, `yum`, `apk`, `pip`, etc. |
| 4 | Are we blocked on network/DNS/metadata? | `dig`, `curl`, `systemd-resolve --status` |
| 5 | Is systemd waiting for services? | `systemd-analyze critical-chain`, `systemctl list-jobs` |
| 6 | Are readiness/liveness probes gating rollout? | Inspect orchestrator events (ECS, EKS, AKS, etc.) |
| 7 | Is the app itself still warming caches or running migrations? | Application logs, APM traces |

## Detailed checklist

### 1. Image build and startup command
- Confirm the `ENTRYPOINT`/`CMD` pair is correct and does not wrap the real process with extra sleeps.
- Run the image locally with `docker run -it --entrypoint /bin/bash` to inspect `/etc/profile`, `/etc/profile.d`, and bootstrap scripts for expensive operations.
- If you rely on systemd inside the container, ensure `CMD ["/sbin/init"]` is intentional and that you actually need a full init system. Otherwise, switch to a simple process supervisor to avoid systemd's boot sequencing.
- Adopt multi-stage builds so compilation, dependency resolution, and artifact packaging complete in earlier stages rather than at runtime; each stage should copy only the final runnable bits into the slim image.
- Ensure the final stage copies just the binary and required assets—avoid inheriting build tools that slow startup or expand attack surface.
- Audit the Dockerfile for explicit `sleep`, `wait`, or `timeout` commands that might pause execution; confirm they are still necessary and reduce/inline them into health checks when possible.
- If the Dockerfile uses `HEALTHCHECK` with long `start-period` or `interval` values, verify those settings match the actual app warm-up profile.

### 2. Logging and visibility
- Enable shell tracing (`set -euxo pipefail`) in bootstrap scripts and send logs to stdout so that `docker logs` (or `kubectl logs`) show where the pause occurs.
- Capture timestamps early in the script: `date '+%F %T.%3N boot: reached step X'` to spot gaps.
- Use `AWS_EXECUTION_ENV` or another env var to emit environment metadata useful for correlating with orchestrator events.

### 3. Package and dependency provisioning
- Many images run package managers (`apt`, `dnf`, `yum`, `apk`, `pip`) inside entrypoint scripts; move these operations to build time so runtime boot stays fast.
- Pre-download large machine learning models, language packs, or CA bundles as image layers instead of runtime downloads.
- If you must install packages on startup, parallelize downloads and set `DNF_ASSUME_YES=1` to avoid interactive waits.

### 4. Systemd/Init inside the container
- Run `systemd-analyze blame` and `systemd-analyze critical-chain` to see which units delay boot.
- Mask services you do not need (e.g., `systemctl mask kubelet.service`).
- Ensure `cloud-init`, `chronyd`, or `amazon-ssm-agent` are not enabled unless required.

### 5. Network, DNS, and metadata calls
- Some base images attempt to resolve cloud metadata service URLs (AWS IMDS, Azure IMDS, GCP metadata) before boot. In other environments this can hang until timeout. Stub those calls or configure timeouts.
- Validate DNS works: `dig +trace your-endpoint`, `getent hosts <service>`.
- Check outbound firewall rules / proxy requirements; curls that retry with exponential backoff can consume the entire 5 minutes.

### 6. Application-level prerequisites
- Database migrations, schema sync, cache warm-ups, or external API health checks can stall readiness. Profile them and consider running them as separate jobs.
- Review how readiness/liveness probes are defined. A readiness probe timeout of 5 minutes may simply reflect the application's intentional warm-up window.
- Add application-level log markers (e.g., `APP_READY` event) to differentiate between infrastructure vs. business logic latency.

### 7. Resource limits and cgroup pressure
- Inspect `docker stats` / `kubectl top pod` to see if CPU throttling or insufficient memory is stretching init time.
- For JVM/.NET runtimes, confirm the container-aware settings (e.g., `-XX:+UseContainerSupport`) and tune heap sizes so GC does not run large compactions on boot.

### 8. Security agents and scanning
- Determine whether vulnerability scanners, file-integrity monitoring, or SSM/Inspector agents run at startup. Disable or background them unless required.
- If using AWS Secrets Manager/SSM Parameter Store, cache secrets via init containers or bake them in encrypted files to avoid sequential API calls.

### 9. Volume mounts and attached storage
- List every `VOLUME` directive or runtime bind mount (`-v`, `--mount`) and confirm attached paths are available immediately; network file systems may require extra time to establish sessions.
- Check init scripts for operations like `fsck`, `chown -R`, `chmod -R`, or bulk data migrations that run against mounted volumes before the app starts.
- For ephemeral volumes, ensure population tasks (e.g., `rsync` from image to volume) run only once or in the background; otherwise, they add minutes to every boot.
- Validate persistent volumes are not stuck waiting for cloud control plane attachment events (EBS, Azure Disk, etc.); inspect orchestrator events for `AttachVolume` latency.

## Diagnostic commands

```bash
# Enter container with debugging shell
docker run --rm -it --entrypoint /bin/bash my-image:tag

# Trace startup script to find slow sections
bash -x /usr/local/bin/entrypoint.sh 2>&1 | ts '%H:%M:%S'

# Measure systemd boot path (only if systemd is PID 1)
systemd-analyze critical-chain
systemctl list-jobs

# Capture strace timeline for the main process
strace -f -tt -o boot.strace /path/to/app

# Monitor network attempts
tcpdump -nn -i eth0 host <service>
```

## Remediation ideas
- Pre-bake dependencies and OS updates into the image to keep runtime startup deterministic.
- Replace long sequential boot scripts with parallelized tasks or background jobs.
- Tighten timeouts and retries for optional network calls; fail fast with clear log messages.
- Add structured logging hooks (JSON with timestamps) so boot regressions are obvious during deployments.
- Maintain a `.dockerignore` file that excludes build artifacts, node_modules/vendor trees, git metadata, and local caches so the build context stays small and reproducible.
- Combine `.dockerignore` with multi-stage builds: the first stages download/install everything, later stages copy in only what is needed, ensuring runtime layers stay lean and consistent.


