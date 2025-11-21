#!/bin/bash
# Validate that the hook's LLM matching produces expected outputs

# Get agent descriptions from the hook's cache
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/claude-agents.cache"

if [ ! -f "$CACHE_FILE" ]; then
    echo "❌ Cache file not found. Run discover-agents hook first to generate cache."
    exit 1
fi

# Extract agent descriptions (same format as hook uses)
agent_descriptions=$(awk -F'|' '{print "- " $1 ": " $3}' "$CACHE_FILE")

# Test cases
declare -a test_requests=(
    "optimize this PostgreSQL query"
    "set up Datadog APM tracing in my Python app"
    "help me set up automated testing for my application"
    "design RESTful API endpoints for user management"
)

declare -a expected_outputs=(
    "postgres-pro,backend-developer,code-reviewer,research-analyst"
    "datadog-specialist,python-pro,backend-developer,research-analyst"
    "test-automator,qa-expert,backend-developer,code-reviewer"
    "api-designer,backend-developer,documentation-engineer,code-reviewer"
)

echo "🧪 Testing Hook LLM Matching Output"
echo "===================================="
echo ""

total=0
passed=0

for i in "${!test_requests[@]}"; do
    request="${test_requests[$i]}"
    expected="${expected_outputs[$i]}"

    total=$((total + 1))
    echo "Test $total: $request"
    echo "Expected: $expected"

    # Use the exact same prompt as the updated hook
    prompt="Analyze this request and suggest 1-5 most relevant agents.

REQUEST: $request

AGENTS:
$agent_descriptions

CRITICAL: Return ONLY comma-separated agent names (e.g., agent1,agent2) or NONE if unclear.

STRICT RULES:
- NO explanations, rationales, or reasoning
- NO extra text before or after the agent names
- JUST the comma-separated list, nothing else
- If unclear, return exactly: NONE"

    # Call Claude Haiku with the same settings as the hook
    result=$(export CLAUDE_IN_HOOK=1; echo "$prompt" | claude --model haiku --print --dangerously-skip-permissions --tools "" 2>/dev/null)

    # Clean output (same as hook does)
    actual=$(echo "$result" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "Actual:   $actual"

    # Compare
    if [ "$actual" = "$expected" ]; then
        echo "✅ EXACT MATCH"
        passed=$((passed + 1))
    else
        # Check if agents overlap (F1 calculation)
        IFS=',' read -ra expected_arr <<< "$expected"
        IFS=',' read -ra actual_arr <<< "$actual"

        # Count matches
        matches=0
        for exp_agent in "${expected_arr[@]}"; do
            for act_agent in "${actual_arr[@]}"; do
                if [ "$exp_agent" = "$act_agent" ]; then
                    matches=$((matches + 1))
                    break
                fi
            done
        done

        precision=$(echo "scale=2; $matches / ${#actual_arr[@]}" | bc)
        recall=$(echo "scale=2; $matches / ${#expected_arr[@]}" | bc)

        echo "⚠️  PARTIAL MATCH - Precision: $precision, Recall: $recall, Matches: $matches/${#expected_arr[@]}"
    fi
    echo ""
done

echo "===================================="
echo "Results: $passed/$total exact matches"
success_rate=$(echo "scale=2; $passed * 100 / $total" | bc)
echo "Success Rate: $success_rate%"
