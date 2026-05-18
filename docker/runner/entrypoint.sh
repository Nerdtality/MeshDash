#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════════════
# MeshDash R3.0 Docker Runner — Entrypoint
#
# Boot sequence:
#   1. Validate MD_SETUP_KEY and MD_SETUP_URL
#   2. Query MeshDash server for target version + zip URL
#   3. If update needed: download, extract, create /opt/venv from requirements.txt
#   4. Fetch latest config
#   5. Seed the R3 bootstrap marker (skip self-heal on clean Docker installs)
#   6. Start MeshDash via /opt/venv/bin/python
# ═══════════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════"
echo "  🦀 MeshDash R3.0 Docker Runner"
echo "══════════════════════════════════════════════"

# ── 1. Validate Environment ──────────────────────────────────────
if [ -z "$MD_SETUP_KEY" ] || [ -z "$MD_SETUP_URL" ]; then
    echo "[ERROR] Missing MD_SETUP_KEY or MD_SETUP_URL environment variables."
    echo ""
    echo "Set them with:"
    echo "  -e MD_SETUP_KEY=\"MD-YOUR-KEY-HERE\""
    echo "  -e MD_SETUP_URL=\"https://meshdash.co.uk/user_setup_core.php\""
    echo ""
    echo "Generate your key at: https://meshdash.co.uk/"
    sleep 300
    exit 1
fi

# ── 2. Get Version Info from Server ──────────────────────────────
echo "[INFO] Contacting MeshDash server for install info..."
RESPONSE=$(curl -sf "${MD_SETUP_URL}?action=get_install_info&key=${MD_SETUP_KEY}" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    echo "[ERROR] Failed to contact MeshDash server."
    echo "[ERROR] Check your network connection and MD_SETUP_URL."
    sleep 300
    exit 1
fi

TARGET_VERSION=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['install_info']['version'])" 2>/dev/null)
ZIP_URL=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['install_info']['zip_url'])" 2>/dev/null)
CONFIG_URL=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['install_info']['config_url'])" 2>/dev/null)

if [ -z "$TARGET_VERSION" ] || [ -z "$ZIP_URL" ]; then
    echo "[ERROR] Invalid response from server."
    echo "[ERROR] Response: $RESPONSE"
    sleep 300
    exit 1
fi

echo "[INFO] Server target version: $TARGET_VERSION"

# ── 3. Check Local Version ──────────────────────────────────────
CURRENT_VERSION="none"
if [ -f "version.tag" ]; then
    CURRENT_VERSION=$(cat version.tag)
fi

# ── 4. Update / Install Logic ────────────────────────────────────
if [ "$CURRENT_VERSION" != "$TARGET_VERSION" ] || [ ! -f "meshtastic_dashboard.py" ]; then
    echo "[INFO] Update required (Current: $CURRENT_VERSION → Target: $TARGET_VERSION)"

    # Preserve data directory and config before cleaning
    echo "[INFO] Preserving data/ and .mesh-dash_config..."
    if [ -d "data" ]; then
        mv data /tmp/data_backup 2>/dev/null || true
    fi
    if [ -f ".mesh-dash_config" ]; then
        cp .mesh-dash_config /tmp/config_backup 2>/dev/null || true
    fi

    # Clean old app files (preserve data and config)
    echo "[INFO] Cleaning old files..."
    find . -maxdepth 1 -type f -not -name '.mesh-dash_config' -not -name 'version.tag' -delete
    find . -maxdepth 1 -type d -not -name '.' -not -name 'data' -exec rm -rf {} +

    # Download and extract
    echo "[INFO] Downloading MeshDash $TARGET_VERSION..."
    wget -q "$ZIP_URL" -O app.zip

    echo "[INFO] Extracting..."
    unzip -o -q app.zip
    rm app.zip

    # Restore data directory
    if [ -d "/tmp/data_backup" ]; then
        # Merge — keep existing data, add new files if any
        cp -rn /tmp/data_backup/* data/ 2>/dev/null || true
        rm -rf /tmp/data_backup
    fi

    # Build /opt/venv from the shipped requirements.txt
    # This mirrors the app Dockerfile's build-time venv creation
    if [ -f "requirements.txt" ]; then
        echo "[INFO] Building Python virtual environment (/opt/venv)..."
        python3 -m venv /opt/venv
        /opt/venv/bin/pip install --upgrade pip -q
        echo "[INFO] Installing dependencies from requirements.txt..."
        /opt/venv/bin/pip install --no-cache-dir -r requirements.txt
    else
        echo "[WARN] No requirements.txt found — skipping dependency install"
    fi

    # Seed the R3 bootstrap marker so the self-heal routine
    # knows this is a clean Docker install, not a dirty R2→R3 overlay
    mkdir -p data
    touch data/.r3_bootstrap_done

    # Mark version
    echo "$TARGET_VERSION" > version.tag
    echo "[INFO] Update complete — now at $TARGET_VERSION"
else
    echo "[INFO] Version $CURRENT_VERSION is up to date."
fi

# ── 5. Ensure /opt/venv exists ───────────────────────────────────
# On restarts without an update, the venv should already be there
if [ ! -d "/opt/venv" ] || [ ! -f "/opt/venv/bin/python3" ]; then
    if [ -f "requirements.txt" ]; then
        echo "[INFO] /opt/venv missing — rebuilding..."
        python3 -m venv /opt/venv
        /opt/venv/bin/pip install --upgrade pip -q
        /opt/venv/bin/pip install --no-cache-dir -r requirements.txt
    fi
fi

# ── 6. Fetch Latest Config ───────────────────────────────────────
echo "[INFO] Refreshing configuration..."
curl -sf "${MD_SETUP_URL}?action=download_config&key=${MD_SETUP_KEY}" -o .mesh-dash_config 2>/dev/null || {
    echo "[WARN] Could not download config — using existing config if present"
}

# Restore config backup if download failed and we had one
if [ ! -s ".mesh-dash_config" ] && [ -f "/tmp/config_backup" ]; then
    cp /tmp/config_backup .mesh-dash_config
    rm -f /tmp/config_backup
    echo "[WARN] Using preserved config (server download failed)"
fi

# ── 7. Determine Port ────────────────────────────────────────────
# Default to 8181 for R3.0+. Config may override.
APP_PORT="${WEBSERVER_PORT:-8181}"

# ── 8. Start MeshDash via /opt/venv ──────────────────────────────
echo "══════════════════════════════════════════════"
echo "  🚀 Starting MeshDash on port $APP_PORT"
echo "══════════════════════════════════════════════"
export PATH="/opt/venv/bin:$PATH"
exec /opt/venv/bin/python3 meshtastic_dashboard.py --host 0.0.0.0 --port "$APP_PORT"