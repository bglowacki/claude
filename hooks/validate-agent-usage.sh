#!/bin/bash

# Agent Usage Validation Hook
# Checks if suggested agents were actually used in responses
# Can be run manually or as a PostToolUse hook

# This script validates that when agents are suggested as REQUIRED,
# they are actually invoked via the Task tool.

# Get the last suggested agents from cache
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/claude-suggested-agents.cache"

if [ ! -f "$CACHE_FILE" ]; then
    # No agents were suggested in recent request
    exit 0
fi

# Read suggested agents and priority
SUGGESTED_AGENTS=$(cat "$CACHE_FILE" | grep "^AGENTS:" | cut -d: -f2-)
MUST_USE_AGENTS=$(cat "$CACHE_FILE" | grep "^MUST_USE:" | cut -d: -f2-)

if [ -z "$SUGGESTED_AGENTS" ]; then
    exit 0
fi

# Check if the user's conversation shows Task tool usage
# This is a simplified check - in practice, this would need to parse
# the conversation history or be triggered after the assistant's response

cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 AGENT DELEGATION CHECKPOINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The following agents were suggested for your last request:
   $SUGGESTED_AGENTS

EOF

if [ -n "$MUST_USE_AGENTS" ]; then
    cat <<EOF
🔴 MUST USE agents: $MUST_USE_AGENTS

⚠️  REMINDER: If these agents were NOT used, the response may be:
   - Based on outdated training data
   - Missing domain-specific expertise
   - Lacking current documentation validation
   - Lower quality than specialist agents would provide

To verify agent usage, check if you see:
   "I'll use the Task tool to invoke [agent-name]..."

If not, consider asking Claude to re-answer using the suggested agents.

EOF
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Clean up cache after showing
rm -f "$CACHE_FILE"
