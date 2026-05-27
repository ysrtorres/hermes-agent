#!/bin/sh
# Bootstrap script for Hermes Agent on Railway.
# Writes a minimal config.yaml on first boot, then runs the gateway.
# Invoked via Railway "Custom Start Command":
#   sh -c "chown -R 10000:10000 /opt/data; exec /init /opt/hermes/docker/main-wrapper.sh sh /opt/hermes/start-on-railway.sh"
set -e

CFG="${HERMES_HOME:-/opt/data}/config.yaml"
SEED_VERSION="2"
SEED_MARKER="${HERMES_HOME:-/opt/data}/.bootstrap-seed-v${SEED_VERSION}"

# Force re-seed when bumping SEED_VERSION (config schema changed).
if [ ! -f "$SEED_MARKER" ]; then
    echo "[start-on-railway] Seeding $CFG (v${SEED_VERSION})"
    cat > "$CFG" <<'YAML'
model:
  default: gpt-5
  provider: openai-api
terminal:
  backend: local
  timeout: 180
memory:
  memory_enabled: true
  user_profile_enabled: true
compression:
  enabled: true
  threshold: 0.50
agent:
  max_turns: 90
display:
  tool_progress: all
approvals:
  mode: manual
YAML
    touch "$SEED_MARKER"
else
    echo "[start-on-railway] config seed v${SEED_VERSION} already applied, leaving $CFG alone"
fi

exec hermes gateway run
