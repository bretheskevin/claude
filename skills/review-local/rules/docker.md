## Dockerfile & Docker Compose Best Practices

**Base image selection**:
- Flag `latest` tags — use pinned versions or SHA256 digests (`image@sha256:...`) for reproducibility
- Flag base images without a digest when a digest-pinned pattern exists elsewhere in the project — inconsistent pinning
- Flag using a full OS image (`ubuntu`, `debian`) when a slim/alpine variant would suffice — unnecessary image size
- Flag switching base image distro without justification — may break dependencies

**Multi-stage builds**:
- Flag `COPY . .` in final stage when only build artifacts are needed — use targeted `COPY --from=builder` to keep image small
- Flag missing multi-stage build when a build step (npm build, go build, bundle install) produces artifacts — shipping dev deps and source to production
- Flag unused stages (stages defined but never referenced by `COPY --from` or `--target`) — dead code

**Layer caching & ordering**:
- Flag `COPY . .` before dependency install (`npm install`, `bundle install`, `pip install`, `go mod download`) — invalidates cache on every source change; copy lockfile first, install deps, then copy source
- Flag `apt-get update` and `apt-get install` in separate `RUN` layers — stale index cache; combine into one `RUN`
- Flag `RUN` commands that could be merged — each `RUN` creates a layer; combine related commands with `&&`

**Security**:
- Flag `USER root` in final stage or missing `USER` directive — containers should not run as root in production
- Flag `chmod 777` — overly permissive; use minimal required permissions
- Flag `--privileged` in docker-compose — grants full host access; rarely justified
- Flag secrets (passwords, tokens, API keys) in `ENV`, `ARG`, or `COPY`'d files — use Docker secrets, build secrets (`--mount=type=secret`), or runtime env injection
- Flag `ARG` used for secrets — ARG values are visible in image history (`docker history`)
- Flag `curl | sh` or `wget | bash` pipe-to-shell patterns — verify integrity with checksums or GPG
- Flag missing `--no-cache-dir` on `pip install` — wastes space, potential info leak
- Flag missing `rm -rf /var/lib/apt/lists/*` after `apt-get install` — wastes 20-50MB per layer

**Reproducibility**:
- Flag `apt-get install <package>` without version pinning — builds may break silently on package updates
- Flag `npm install` (without `ci`) in Dockerfiles — `npm ci` is deterministic and respects lockfile
- Flag `ADD` when `COPY` suffices — `ADD` has implicit tar extraction and URL fetch behaviors that are surprising; use `COPY` unless you need those features
- Flag `.dockerignore` missing or not excluding `.git`, `node_modules`, `tmp`, `log`, `.env` — bloated context, potential secret leakage

**Health checks**:
- Flag long-running services in docker-compose without `healthcheck` — orchestration can't know if the service is actually ready
- Flag `depends_on` without `condition: service_healthy` when the dependency has a healthcheck — race condition on startup order
- Flag healthcheck commands that test the wrong thing (e.g., `true` or process existence instead of actual endpoint readiness)

**Docker Compose specifics**:
- Flag hardcoded port numbers that should come from environment variables — conflicts across environments
- Flag `restart: always` without a healthcheck — restarts broken containers forever without detection
- Flag `volumes` mounting sensitive host paths (`/`, `/etc`, `~/.ssh`) — security exposure
- Flag missing `networks` isolation — all services on default bridge can reach each other
- Flag `build: .` without explicit `context` and `dockerfile` — ambiguous when multiple Dockerfiles exist
- Flag `env_file` pointing to `.env` committed to git — secrets in version control
- Flag `container_name` in production-oriented compose — prevents scaling (`docker-compose up --scale`)
- Flag `links` — deprecated; use `networks` and service DNS

**Resource constraints**:
- Flag missing `mem_limit` / `memswap_limit` for production services in compose — unbounded memory can crash the host
- Flag missing `cpus` limits on CPU-intensive services — one runaway container starves others
- Flag `shm_size` set unnecessarily large — default 64MB is sufficient for most workloads

**Entrypoint & CMD**:
- Flag `CMD` in exec form with shell features (`CMD ["sh", "-c", "..."]` for complex logic) — use an entrypoint script instead
- Flag `ENTRYPOINT` without `CMD` default — no way to override args easily
- Flag `CMD` using shell form when exec form works — shell form doesn't receive signals properly (PID 1 issues)
- Flag `ENTRYPOINT` that doesn't use `exec` to replace the shell process — signal forwarding broken, zombie processes
