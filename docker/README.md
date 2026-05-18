# Docker

MeshDash provides two Docker images:

## App Image (`docker/Dockerfile`)

Bundles the full R3.0 source code. Best for offline/air-gapped deployments or when you want a fixed version.

```bash
docker build -t meshdash:r3.0 -f docker/Dockerfile .
docker run -d --name meshdash --network host meshdash:r3.0
```

## Runner Image (`docker/runner/Dockerfile`)

Self-updating thin bootstrap image. Downloads and installs MeshDash from meshdash.co.uk on first boot, auto-updates on restarts. This is the image published to Docker Hub as `rusjpmd/meshdash-runner`.

```bash
docker run -d \
  --name meshdash \
  --restart always \
  --network host \
  --privileged \
  -v /dev:/dev \
  -v meshdash_data:/app/data \
  -e MD_SETUP_KEY="MD-YOUR-KEY-HERE" \
  -e MD_SETUP_URL="https://meshdash.co.uk/user_setup_core.php" \
  rusjpmd/meshdash-runner:latest
```

Generate your setup key at [meshdash.co.uk](https://meshdash.co.uk/).

### Required Flags

| Flag | Purpose |
|------|---------|
| `--network host` | Access host networking for local Meshtastic device discovery |
| `--privileged` | Required for Serial/USB access to the radio |
| `-v /dev:/dev` | Maps host device tree so the container can see serial hardware |
| `-v meshdash_data:/app/data` | Persists database, logs, and settings across updates |

### Ports

R3.0+ defaults to **8181** (V2 used 8000). Override with `WEBSERVER_PORT` env var.