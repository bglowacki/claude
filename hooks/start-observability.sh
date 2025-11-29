#!/bin/bash
# Auto-start observability server if not running

OBSERVABILITY_DIR="$HOME/.claude/observability"

# Create .env from sample if missing
if [ ! -f "$OBSERVABILITY_DIR/.env" ]; then
  if [ -f "$OBSERVABILITY_DIR/.env.sample" ]; then
    cp "$OBSERVABILITY_DIR/.env.sample" "$OBSERVABILITY_DIR/.env"
    echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" > "$OBSERVABILITY_DIR/.env"
    echo "ENGINEER_NAME=$(whoami)" >> "$OBSERVABILITY_DIR/.env"
  fi
fi

# Install dependencies if node_modules missing
if [ ! -d "$OBSERVABILITY_DIR/apps/server/node_modules" ]; then
  cd "$OBSERVABILITY_DIR/apps/server" && mise exec -- bun install
fi

if [ ! -d "$OBSERVABILITY_DIR/apps/client/node_modules" ]; then
  cd "$OBSERVABILITY_DIR/apps/client" && mise exec -- bun install
fi

# Start server and client if not running
if ! lsof -i:4000 > /dev/null 2>&1; then
  cd "$OBSERVABILITY_DIR"

  # Start server (port 4000)
  nohup mise exec -- bun run --cwd apps/server start > /dev/null 2>&1 &

  # Start client (port 5173)
  nohup mise exec -- bun run --cwd apps/client dev > /dev/null 2>&1 &

  # Wait for server to be ready
  sleep 2
fi
