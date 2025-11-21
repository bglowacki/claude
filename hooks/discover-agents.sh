#!/bin/bash

# Optimized Hybrid Intelligent Agent Selection Hook
# Fast bash globbing + mtime-based caching + keyword/LLM matching

# CRITICAL: Prevent infinite loop
if [ "$CLAUDE_IN_HOOK" = "1" ]; then
    # Fast path for recursive calls
    agents=""
    shopt -s nullglob
    for file in "$HOME/.claude/agents"/*.md; do
        agents+="$(basename "$file" .md),"
    done
    skills=""
    for file in "$HOME/.claude/skills"/*/SKILL.md; do
        skills+="$(basename "$(dirname "$file")"),"
    done
    shopt -u nullglob
    echo "Available agents: ${agents%,}"
    echo "Available skills: ${skills%,}"
    exit 0
fi

USER_REQUEST="${CLAUDE_USER_MESSAGE:-}"
QUIET_MODE="${CLAUDE_HOOK_QUIET:-false}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/claude-agents.cache"

# Extract description from agent file (bash-native, no subprocess)
extract_description() {
    local file="$1"
    local in_frontmatter=false

    while IFS= read -r line; do
        # Skip first --- line
        if [[ "$line" =~ ^---$ ]]; then
            if [[ "$in_frontmatter" = true ]]; then
                # Second ---, end of frontmatter
                return 1
            else
                # First ---, entering frontmatter
                in_frontmatter=true
                continue
            fi
        fi

        # Extract description
        if [[ "$in_frontmatter" = true ]] && [[ "$line" =~ ^description:[[:space:]]*(.+)$ ]]; then
            echo "${BASH_REMATCH[1]}"
            return 0
        fi
    done < "$file"
}

# Build agent cache
build_agent_cache() {
    local cache_data=""

    # Cache agents
    shopt -s nullglob
    for file in "$HOME/.claude/agents"/*.md; do
        local name=$(basename "$file" .md)
        local desc=$(extract_description "$file")
        cache_data+="AGENT|$name|${desc:-No description}"$'\n'
    done

    # Cache skills
    for file in "$HOME/.claude/skills"/*/SKILL.md; do
        local name=$(basename "$(dirname "$file")")
        local desc=$(extract_description "$file")
        cache_data+="SKILL|$name|${desc:-No description}"$'\n'
    done
    shopt -u nullglob

    echo "$cache_data"
}

# Load or build cache
get_cached_metadata() {
    local agents_dir="$HOME/.claude/agents"
    local skills_dir="$HOME/.claude/skills"
    local rebuild=false

    # Check if cache exists
    if [[ ! -f "$CACHE_FILE" ]]; then
        rebuild=true
    else
        # Compare directory mtimes with cache mtime
        if [[ -d "$agents_dir" ]]; then
            local agents_mtime=$(stat -f "%m" "$agents_dir" 2>/dev/null || echo 0)
            local cache_mtime=$(stat -f "%m" "$CACHE_FILE" 2>/dev/null || echo 0)
            [[ "$agents_mtime" -gt "$cache_mtime" ]] && rebuild=true
        fi

        if [[ -d "$skills_dir" ]] && [[ "$rebuild" = false ]]; then
            local skills_mtime=$(stat -f "%m" "$skills_dir" 2>/dev/null || echo 0)
            local cache_mtime=$(stat -f "%m" "$CACHE_FILE" 2>/dev/null || echo 0)
            [[ "$skills_mtime" -gt "$cache_mtime" ]] && rebuild=true
        fi
    fi

    if [[ "$rebuild" = true ]]; then
        mkdir -p "$CACHE_DIR"
        build_agent_cache > "$CACHE_FILE"
    fi

    cat "$CACHE_FILE"
}

# Fast agent discovery from cache
discover_agents() {
    local agents=()

    while IFS='|' read -r type name desc; do
        [[ "$type" = "AGENT" ]] && agents+=("$name")
    done < <(get_cached_metadata)

    # Add project-local agents (not cached, rare)
    shopt -s nullglob
    for file in "./.claude/agents"/*.md; do
        agents+=("$(basename "$file" .md) (local)")
    done
    shopt -u nullglob

    printf '%s' "$(IFS=', '; echo "${agents[*]}")"
}

# Fast skill discovery from cache
discover_skills() {
    local skills=()

    while IFS='|' read -r type name desc; do
        [[ "$type" = "SKILL" ]] && skills+=("$name")
    done < <(get_cached_metadata)

    # Add project-local skills (not cached, rare)
    shopt -s nullglob
    for file in "./.claude/skills"/*/SKILL.md; do
        skills+=("$(basename "$(dirname "$file")") (local)")
    done
    shopt -u nullglob

    printf '%s' "$(IFS=', '; echo "${skills[*]}")"
}

# Fast keyword matching using cached metadata
keyword_match_agents() {
    local request="$1"
    local request_lower=$(echo "$request" | tr '[:upper:]' '[:lower:]')
    local matched_agents=()

    while IFS='|' read -r type name description; do
        [[ "$type" != "AGENT" ]] && continue

        local desc_lower=$(echo "$description" | tr '[:upper:]' '[:lower:]')
        local matched=false

        # Event Sourcing
        if echo "$request_lower" | grep -qE "projection|event.?sourc|aggregate|domain.?event|cqrs"; then
            echo "$desc_lower" | grep -qE "projection|event.?sourc|aggregate|domain.?event|cqrs" && matched=true
        fi

        # Database/PostgreSQL
        if echo "$request_lower" | grep -qE "postgres|database|\bsql\b|query|index|migration"; then
            echo "$desc_lower" | grep -qE "postgres|database|sql|query" && matched=true
        fi

        # Testing/QA
        if echo "$request_lower" | grep -qE "\btest\b|\bqa\b|quality|coverage"; then
            echo "$desc_lower" | grep -qE "test|qa|quality|coverage" && matched=true
        fi

        # Debugging
        if echo "$request_lower" | grep -qE "debug|error|\bbug\b|fail|crash|\bdie\b"; then
            echo "$desc_lower" | grep -qE "debug|diagnos|troubleshoot|error" && matched=true
        fi

        # Logging/Monitoring
        if echo "$request_lower" | grep -qE "\blog\b|\bmonitor|\bobserv|metrics|telemetry|instrument|trace"; then
            echo "$desc_lower" | grep -qE "log|monitor|observ|metrics|telemetry" && matched=true
        fi

        # API/Backend
        if echo "$request_lower" | grep -qE "\bapi\b|endpoint|rest|graphql|backend"; then
            echo "$desc_lower" | grep -qE "api|endpoint|rest|graphql|backend" && matched=true
        fi

        # Security
        if echo "$request_lower" | grep -qE "security|vulnerab|penetrat|auth|permission"; then
            echo "$desc_lower" | grep -qE "security|vulnerab|audit|auth" && matched=true
        fi

        # Performance
        if echo "$request_lower" | grep -qE "performance|optim|slow|bottleneck|profil"; then
            echo "$desc_lower" | grep -qE "performance|optim|profil|bottleneck" && matched=true
        fi

        # Research/Documentation
        if echo "$request_lower" | grep -qE "research|documentation|\bhow does\b|\bhow do\b|look up|fetch docs|best practices|docs for|library.*docs|framework.*docs|api reference|\bfind docs\b|\bget docs\b"; then
            echo "$desc_lower" | grep -qE "research|documentation|information gathering|best practices|comprehensive" && matched=true
        fi

        # Infrastructure
        if echo "$request_lower" | grep -qE "kubernetes|k8s|container|docker|deploy|infra"; then
            echo "$desc_lower" | grep -qE "kubernetes|k8s|container|docker|deploy" && matched=true
        fi

        # Python
        if echo "$request_lower" | grep -qE "python|django|fastapi"; then
            echo "$desc_lower" | grep -qE "python|django|fastapi" && matched=true
        fi

        [[ "$matched" = true ]] && matched_agents+=("$name")
    done < <(get_cached_metadata)

    if [ ${#matched_agents[@]} -gt 0 ]; then
        printf '%s\n' "${matched_agents[@]}" | sort -u | head -5 | tr '\n' ',' | sed 's/,$//'
        return 0
    fi
    return 1
}

# LLM matching (only for ambiguous cases)
llm_match_agents() {
    local request="$1"
    local agent_descriptions=""

    while IFS='|' read -r type name description; do
        [[ "$type" = "AGENT" ]] && agent_descriptions+="- $name: $description"$'\n'
    done < <(get_cached_metadata)

    [[ -z "$agent_descriptions" ]] && return 1

    local prompt="Analyze this request and suggest 1-5 most relevant agents.

REQUEST: $request

AGENTS:
$agent_descriptions

CRITICAL: Return ONLY comma-separated agent names (e.g., agent1,agent2) or NONE if unclear.

STRICT RULES:
- NO explanations, rationales, or reasoning
- NO extra text before or after the agent names
- JUST the comma-separated list, nothing else
- If unclear, return exactly: NONE"

    local result=$(export CLAUDE_IN_HOOK=1; echo "$prompt" | claude --model haiku --print --dangerously-skip-permissions --tools "" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$result" ] && [ "$result" != "NONE" ]; then
        echo "$result" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
        return 0
    fi
    return 1
}

# Check if request is ambiguous
is_ambiguous_request() {
    local request="$1"
    local request_lower=$(echo "$request" | tr '[:upper:]' '[:lower:]')
    local word_count=$(echo "$request" | wc -w | tr -d ' ')

    [[ "$word_count" -lt 5 ]] && return 0

    if echo "$request_lower" | grep -qE "^(check|improve|analyze|review|fix|help)" &&
       ! echo "$request_lower" | grep -qE "test|database|api|python|event|project|deploy|security|performance"; then
        return 0
    fi

    return 1
}

# Analyze parallelization
analyze_parallelization() {
    local request="$1"
    local request_lower=$(echo "$request" | tr '[:upper:]' '[:lower:]')

    if echo "$request_lower" | grep -qE "\ball (agents|skills|components|files|modules)\b"; then
        echo "PARALLEL_NEEDED:Request targets multiple items - process EACH in PARALLEL"
    elif echo "$request_lower" | grep -qE "(analyze|review|check|improve).*(and|,).*\b(test|document|deploy)"; then
        echo "PARALLEL_NEEDED:Multiple independent tasks detected - execute in PARALLEL"
    elif echo "$request_lower" | grep -qE "multiple|several|various"; then
        echo "PARALLEL_HINT:Multiple items mentioned - consider PARALLEL processing"
    fi
}

# Classify agent priority based on description
classify_agent_priority() {
    local agent="$1"
    local desc=""

    while IFS='|' read -r type name description; do
        if [[ "$type" = "AGENT" ]] && [[ "$name" = "$agent" ]]; then
            desc="$description"
            break
        fi
    done < <(get_cached_metadata)

    # MUST USE: Proactive agents with explicit auto-engage instructions
    if echo "$desc" | grep -qE "PROACTIVE|MUST BE USED|auto-engages|automatically engages|Use WITHOUT waiting"; then
        echo "MUST"
        return 0
    fi

    # SHOULD USE: Other specialized agents
    echo "SHOULD"
}

# Main execution
ALL_AGENTS=$(discover_agents)
ALL_SKILLS=$(discover_skills)
MATCHED_AGENTS=""
MATCH_METHOD=""

if [ -n "$USER_REQUEST" ]; then
    # Try fast keyword matching first
    MATCHED_AGENTS=$(keyword_match_agents "$USER_REQUEST")

    if [ $? -eq 0 ]; then
        MATCH_METHOD="keyword"
    elif is_ambiguous_request "$USER_REQUEST"; then
        # Fallback to LLM for ambiguous requests
        MATCHED_AGENTS=$(llm_match_agents "$USER_REQUEST")
        [[ $? -eq 0 ]] && MATCH_METHOD="llm"
    fi
fi

# Classify matched agents by priority
MUST_USE_AGENTS=()
SHOULD_USE_AGENTS=()

if [ -n "$MATCHED_AGENTS" ]; then
    for agent in $(echo "$MATCHED_AGENTS" | tr ',' ' '); do
        priority=$(classify_agent_priority "$agent")
        if [ "$priority" = "MUST" ]; then
            MUST_USE_AGENTS+=("$agent")
        else
            SHOULD_USE_AGENTS+=("$agent")
        fi
    done
fi

# Cache suggested agents for validation hook
VALIDATION_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/claude-suggested-agents.cache"
if [ -n "$MATCHED_AGENTS" ]; then
    mkdir -p "$(dirname "$VALIDATION_CACHE")"
    {
        echo "AGENTS:$MATCHED_AGENTS"
        echo "MUST_USE:$(IFS=','; echo "${MUST_USE_AGENTS[*]}")"
        echo "SHOULD_USE:$(IFS=','; echo "${SHOULD_USE_AGENTS[*]}")"
    } > "$VALIDATION_CACHE"
fi

PARALLEL_HINT=$([ -n "$USER_REQUEST" ] && analyze_parallelization "$USER_REQUEST")

# Output
if [ "$QUIET_MODE" = "false" ]; then
    if [ -n "$MATCHED_AGENTS" ]; then
        cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 REQUIRED AGENTS - MUST DELEGATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

        if [ ${#MUST_USE_AGENTS[@]} -gt 0 ]; then
            echo "🔴 MUST USE (Specialized/Proactive):"
            for agent in "${MUST_USE_AGENTS[@]}"; do
                echo "   → $agent"
            done
            echo
            echo "⚠️  CRITICAL: These agents MUST handle this request."
            echo "   DO NOT answer directly. Use: Task(subagent_type=\"$agent\", ...)"
            echo
        fi

        if [ ${#SHOULD_USE_AGENTS[@]} -gt 0 ]; then
            echo "🟡 SHOULD USE (Recommended):"
            for agent in "${SHOULD_USE_AGENTS[@]}"; do
                echo "   → $agent"
            done
            echo
        fi

        [[ "$MATCH_METHOD" = "llm" ]] && echo "💡 Deep LLM analysis selected these agents for your request."
        [[ "$MATCH_METHOD" = "keyword" ]] && echo "💡 Domain keyword matching identified these specialized agents."
        echo
        echo "📊 Validation: Run ~/.claude/hooks/validate-agent-usage.sh to check if agents were used"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo
    else
        # No agents matched - direct answers are acceptable
        if [ -n "$USER_REQUEST" ]; then
            cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ NO SPECIALIZED AGENTS NEEDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

No domain-specific agents matched this request.

✅ Direct answers are acceptable for:
   • General questions and explanations
   • Simple code operations
   • Clarifications and follow-ups
   • Basic file operations

💡 If you need specialized expertise, try:
   • Being more specific about the domain (AWS, Datadog, testing, etc.)
   • Mentioning specific technologies or frameworks
   • Asking about best practices or documentation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
        fi
    fi

    if [ -n "$PARALLEL_HINT" ]; then
        HINT_TYPE=$(echo "$PARALLEL_HINT" | cut -d: -f1)
        HINT_MSG=$(echo "$PARALLEL_HINT" | cut -d: -f2-)
        if [ "$HINT_TYPE" = "PARALLEL_NEEDED" ]; then
            echo "⚡ PARALLELIZATION REQUIRED:"
            echo "   $HINT_MSG"
            echo
            echo "CRITICAL: Send ONE message with MULTIPLE Task tool calls to run agents in parallel."
            echo
        else
            echo "🔀 PARALLELIZATION HINT:"
            echo "   $HINT_MSG"
            echo
        fi
    fi

    cat <<'EOF'
📋 MANDATORY PARALLELIZATION CHECKLIST:

Before executing, you MUST state:
- Can tasks run independently? [YES/NO]
- If YES: Executing [N] agents in PARALLEL: [list]
- If NO: Sequential because: [reason]

HIGH-VALUE PARALLEL PATTERNS:
• Multi-domain review → Parallel specialized reviewers
• Implementation + testing → implementation agent || test-automator
• Multiple items (agents/files/modules) → One agent per item in PARALLEL
• Testing + documentation → test-automator || documentation-engineer

EOF

    echo "Available agents: $ALL_AGENTS"
    echo "Available skills: $ALL_SKILLS"
else
    [[ -n "$MATCHED_AGENTS" ]] && echo "🎯 Relevant: $MATCHED_AGENTS"
    echo "Available agents: $ALL_AGENTS"
    echo "Available skills: $ALL_SKILLS"
fi
