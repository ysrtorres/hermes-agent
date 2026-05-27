#!/bin/sh
# Bootstrap script for Hermes Agent on Railway.
# Writes a minimal config.yaml on first boot, then runs the gateway.
# Invoked via Railway "Custom Start Command":
#   /init /opt/hermes/docker/main-wrapper.sh sh /opt/hermes/start-on-railway.sh
set -e

CFG="${HERMES_HOME:-/opt/data}/config.yaml"

if [ ! -f "$CFG" ]; then
    echo "[start-on-railway] Seeding $CFG"
    cat > "$CFG" <<'YAML'
model:
  default: gpt-5
  provider: openai
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
else
    echo "[start-on-railway] $CFG already exists, skipping seed"
fi

exec hermes gateway run
