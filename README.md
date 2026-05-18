<p align="center">
  <img src="https://meshdash.co.uk/static/icons/meshdash-logo.png" alt="MeshDash" width="120" />
</p>

<h1 align="center">MeshDash</h1>

<p align="center">
  Open-source self-hosted Meshtastic Command & Control dashboard<br>
  Manage, monitor, and automate your mesh network locally
</p>

<p align="center">
  <a href="https://meshdash.co.uk">Website</a> ·
  <a href="https://meshdash.co.uk/docs/">Documentation</a> ·
  <a href="https://meshdash.co.uk/?p=install">Install</a> ·
  <a href="https://meshdash.co.uk/docs/?page=api-core">REST API</a> ·
  <a href="https://meshdash.co.uk/docs/?page=plugin-development">Plugins</a>
</p>

<p align="center">
  <a href="https://www.wikidata.org/wiki/Q139844395"><img src="https://img.shields.io/badge/Wikidata-Q139844395-blue" alt="Wikidata" /></a>
  <a href="https://meshdash.co.uk"><img src="https://img.shields.io/badge/Website-meshdash.co.uk-green" alt="Website" /></a>
  <img src="https://img.shields.io/badge/version-R3.0-orange" alt="Version" />
  <img src="https://img.shields.io/badge/license-GPL--3.0--only-blue" alt="License" />
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20Raspberry%20Pi%20%7C%20WSL2-lightgrey" alt="Platform" />
</p>

---

## Features

### Live Node C2
Real-time node monitoring with battery, SNR, RSSI, GPS, and signal bars — updated instantly via Server-Sent Events (SSE). No polling lag.

### Interactive Mapping
Leaflet-based GPS map with node positions, trajectory paths, RF neighbour links, and multiple tile styles.

### Messaging
Direct P2P and channel broadcasting with live ACK delivery tracking and unread counters.

### MeshShark Analyser
Wireshark-style packet capture with BPF syntax filtering, raw JSON inspection, decoded metadata, and source evidence scoring.

### Network Diagnostics
Live traceroute for hop-by-hop bidirectional SNR, plotted on maps and logged historically.

### Analytics
9 distinct telemetry metrics charted over 1H–30D ranges. Side-by-side comparison for up to 4 nodes with linked Y-axes.

### Automation & Rules
Telemetry threshold alerts, cron-based message schedulers, regex-powered auto-reply engine, and web telemetry ingress.

### Radio Management
Direct read/write of full protobuf configurations to radio flash memory. Manage up to 16 radios simultaneously with isolated databases.

### Plugin System
Drop-in folder architecture with FastAPI router, static file server, sidebar nav, and lifecycle management. Zero core modifications needed. 30+ community plugins available.

## Technology Stack

| Layer | Technologies |
|---|---|
| **Backend** | Python, FastAPI, SQLite, asyncio |
| **Frontend** | HTML/JS, Server-Sent Events, Web Serial, Leaflet |
| **Security** | JWT, bcrypt, HttpOnly cookies, CSRF double-submit, optional TOTP 2FA |
| **Connectivity** | Serial, TCP, BLE, MQTT, MeshCore, WebSerial |
| **Multi-Radio** | Up to 16 simultaneous radio slots with isolated databases |

## Requirements

- Python 3.9+
- Linux, Raspberry Pi, or WSL2
- A Meshtastic radio (or MQTT observer mode)

## Quick Start

```bash
# Download and run the installer
curl -sL https://meshdash.co.uk/versions/R3.0/install.sh | bash
```

Or follow the full [installation guide](https://meshdash.co.uk/?p=install).

## Multi-Radio Slots

Connect up to 16 Meshtastic radios simultaneously. Each slot gets:
- Its own isolated SQLite database
- Dedicated SSE stream
- Independent connection config
- Mix Serial, TCP, BLE, MQTT, and MeshCore on one dashboard

## REST API

100+ endpoints for integrations. Full documentation at [meshdash.co.uk/docs](https://meshdash.co.uk/docs/?page=api-core).

```bash
# Example: Get all nodes
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://your-meshdash-host/api/v1/nodes
```

## Plugins

MeshDash supports drop-in plugins that extend functionality without touching core code. Build your own or browse the community store.

- [Plugin Development Guide](https://meshdash.co.uk/docs/?page=plugin-development)
- [Plugin Store](https://meshdash.co.uk/?p=plugins)

### Core Plugins Included

`mesh_ping` · `pki_alerts` · `emoji_picker` · `node_ignore` · `tcp_proxy` · `apprise_notify` · `proximity_prune` · `mesh_visualizer` · `google_translate` · `cold_nodes` · `welcome_new` · `node_comparison` · `channel_vault` · `share_map` · `hello_mesh` · `medi` · `node_analytics` · `node_monitor` · `node_admin` · `polar_grid` · and more

## Security

- JWT tokens in HttpOnly, SameSite cookies
- Bcrypt password hashing with automatic salt generation
- CSRF double-submit cookie protection on all state-changing requests
- Optional TOTP two-factor authentication
- Optional remote access with 5-tier HMAC-signed rate-limiting
- Data never leaves the local network unless you explicitly enable community features

## Documentation

| Topic | Link |
|---|---|
| Installation | [meshdash.co.uk/?p=install](https://meshdash.co.uk/?p=install) |
| Security & Auth | [meshdash.co.uk/?p=security](https://meshdash.co.uk/?p=security) |
| Multi-Radio | [meshdash.co.uk/?p=multiradio](https://meshdash.co.uk/?p=multiradio) |
| Hardware Guide | [meshdash.co.uk/?p=hardware](https://meshdash.co.uk/?p=hardware) |
| REST API | [meshdash.co.uk/docs/?page=api-core](https://meshdash.co.uk/docs/?page=api-core) |
| Plugin Dev | [meshdash.co.uk/docs/?page=plugin-development](https://meshdash.co.uk/docs/?page=plugin-development) |
| Database Schema | [meshdash.co.uk/docs/?page=database-schema](https://meshdash.co.uk/docs/?page=database-schema) |
| Changelog | [meshdash.co.uk/?p=changelog](https://meshdash.co.uk/?p=changelog) |

## License

MeshDash is licensed under [GPL-3.0-only](LICENSE).

---

<p align="center">
  Built for operators who run their own infrastructure.
</p>