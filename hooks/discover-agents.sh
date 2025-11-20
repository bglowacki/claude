#!/bin/bash

# Discover all available agents (global and project-local)
discover_agents() {
    local agents=()

    # Global agents from ~/.claude/agents/
    if [ -d "$HOME/.claude/agents" ]; then
        while IFS= read -r -d '' file; do
            agent_name=$(basename "$file" .md)
            agents+=("$agent_name")
        done < <(find "$HOME/.claude/agents" -name "*.md" -print0 2>/dev/null)
    fi

    # Project-local agents from ./.claude/agents/
    if [ -d "./.claude/agents" ]; then
        while IFS= read -r -d '' file; do
            agent_name=$(basename "$file" .md)
            # Mark project-local agents with a prefix
            agents+=("$agent_name (local)")
        done < <(find "./.claude/agents" -name "*.md" -print0 2>/dev/null)
    fi

    # Return comma-separated list
    printf '%s' "$(IFS=', '; echo "${agents[*]}")"
}

# Discover all available skills (global and project-local)
discover_skills() {
    local skills=()

    # Global skills from ~/.claude/skills/
    if [ -d "$HOME/.claude/skills" ]; then
        while IFS= read -r -d '' file; do
            skill_name=$(basename "$(dirname "$file")")
            skills+=("$skill_name")
        done < <(find "$HOME/.claude/skills" -name "SKILL.md" -print0 2>/dev/null)
    fi

    # Project-local skills from ./.claude/skills/
    if [ -d "./.claude/skills" ]; then
        while IFS= read -r -d '' file; do
            skill_name=$(basename "$(dirname "$file")")
            # Mark project-local skills with a prefix
            skills+=("$skill_name (local)")
        done < <(find "./.claude/skills" -name "SKILL.md" -print0 2>/dev/null)
    fi

    # Return comma-separated list
    printf '%s' "$(IFS=', '; echo "${skills[*]}")"
}

# Get agent and skill rosters
AGENT_ROSTER=$(discover_agents)
SKILL_ROSTER=$(discover_skills)

# Output parallelization prompt with dynamic agent roster
cat <<'EOF'

🔀 PARALLELIZATION ANALYSIS REQUIRED:

Before executing, analyze this request for parallel agent opportunities:

1. Identify all specialized domains involved
2. Determine which work can proceed independently
3. If 2+ agents can work in parallel, YOU MUST use Task tool with PARALLEL invocations in a SINGLE message
4. Single-agent execution only if task requires single specialization

CRITICAL: To run agents in parallel, send ONE message with MULTIPLE Task tool calls.

HIGH-VALUE PARALLEL PATTERNS:
• Multi-domain review → Use parallel specialized reviewers
• Implementation + testing → Use implementation agent || test-automator
• Testing + documentation → Use test-automator || documentation-engineer
• Code quality + testing → Use code-reviewer || test-automator
• Database + API optimization → Use postgres-pro || api-designer
• Multi-component updates → Use domain-specific agents in parallel
• Working with multiple agents/skills (create/analyze/review/update/improve) → Use toolkit-manager in PARALLEL (one per item)
• Analyzing multiple items (agents/files/modules) → Analyze EACH in parallel when independent

SINGLE-AGENT PATTERNS:
• Specific bug fixes → debugger only
• Code explanation → single analysis
• Focused reviews → single reviewer

EOF

# Output discovered agent and skill rosters
echo "Available agents: $AGENT_ROSTER"
echo "Available skills: $SKILL_ROSTER"
