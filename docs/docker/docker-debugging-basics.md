# Docker Debugging & Basics

Use this reference to help dev, L1, and L2 teams troubleshoot container issues and perform day-to-day Docker tasks.

## 1. Environment checklist
- Docker Desktop/Engine is installed and running (whale icon on macOS / tray icon on Windows).
- `docker version` returns client and server info.
- You are in a shell with permissions to run Docker commands (on Linux, be in the `docker` group or use `sudo`).

## 2. Core commands
| Task | Command | Notes |
| --- | --- | --- |
| List running containers | `docker ps` | Add `-a` to include exited containers. |
| View local images | `docker images` | Shows repository, tag, and image ID. |
| Pull an image | `docker pull nginx:latest` | Downloads from registry. |
| Start a container | `docker run -d --name web -p 8080:80 nginx:alpine` | `-d` detaches, `-p` publishes port. |
| Stop / start container | `docker stop web` / `docker start web` | Graceful stop vs restart. |
| Remove container | `docker rm web` | Use `-f` to force. |
| Remove image | `docker rmi nginx:alpine` | Only after no containers use it. |

## 3. Debugging workflow
1. **Inspect status**: `docker ps -a --filter name=<container>` to see exit codes.
2. **Read logs**: `docker logs <container>` (add `-f` to follow, `--tail 100` for recent lines).
3. **Exec into container**: `docker exec -it <container> /bin/sh` (or `/bin/bash`) to inspect files, run diagnostics.
4. **Check resource usage**: `docker stats <container>` for live CPU/memory; `docker inspect <container>` for configuration details.
5. **Events timeline**: `docker events --since 10m` to trace start/stop/crash events.
6. **Copy files**: `docker cp <container>:/path/file ./local-file` (and the reverse) to gather evidence.

## 4. Common issues & fixes
| Symptom | Checks | Typical fix |
| --- | --- | --- |
| Container exits immediately | `docker logs <name>` | App may require foreground process; adjust entrypoint or command. |
| Port already in use | Look for `bind: address already in use` | Change host port mapping (`-p 8081:80`) or free the port. |
| Image pull fails | `docker login`, network/firewall | Verify registry credentials and network access. |
| Disk full | `docker system df`, `docker ps -a` | Remove unused containers/images (`docker system prune -a`). |
| Permission denied to daemon | On Linux, user not in `docker` group | Add user to `docker` group or run with `sudo`. |

## 5. Cleanup & maintenance
- Remove stopped containers: `docker container prune`
- Remove dangling images: `docker image prune`
- Full cleanup (containers, networks, build cache): `docker system prune -a`
- Use the repo's `scripts/cleanup_docker.sh --dry-run` to preview cleanup before deleting anything.

## 6. Docker Compose quick reference
| Task | Command |
| --- | --- |
| Start services | `docker compose up -d` |
| View logs | `docker compose logs -f <service>` |
| Scale a service | `docker compose up -d --scale api=3` |
| Stop services | `docker compose down` |

## 7. When to escalate
- Repeated crashes due to application errors -> notify owning dev squad with logs (`docker logs --tail 300 <name>`).
- Resource exhaustion on host -> involve platform team to adjust limits.
- Suspected image compromise -> immediately stop container, collect evidence, and contact security.
- Production data corruption -> engage incident-response bridge and do not restart until impact assessed.

Keep this doc handy for quick walkthroughs and share log snippets plus repro steps when raising tickets to higher tiers.
