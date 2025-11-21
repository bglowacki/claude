#!/bin/bash
# Sync agent descriptions from hook cache to promptfoo.yaml

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/claude-agents.cache"

if [ ! -f "$CACHE_FILE" ]; then
    echo "❌ Cache file not found"
    exit 1
fi

echo "Extracting current agent descriptions from cache..."

# Extract AGENT descriptions from cache (skip SKILL entries)
agent_list=$(awk -F'|' '/^AGENT/ {
    name = $2
    desc = $3
    # Escape special characters for YAML
    gsub(/"/, "\\\"", desc)
    print "    - " name ": " desc
}' "$CACHE_FILE")

echo "$agent_list"
echo ""
echo "✅ Found $(echo "$agent_list" | wc -l | tr -d ' ') agents"
echo ""
echo "To update promptfoo.yaml, manually replace the AGENTS section in the prompt with this list."
