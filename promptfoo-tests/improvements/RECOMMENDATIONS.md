# Agent Discovery Hook - Improvement Recommendations

Based on promptfoo test analysis, this document provides specific, actionable recommendations to improve agent matching accuracy from ~20% to 80%+.

## Priority 1: Improve LLM Matching Prompt (HIGH IMPACT)

**Target**: Hook lines 234-241
**Expected Impact**: +30-40% accuracy improvement
**Effort**: Low (single prompt change)

### Current Prompt (Lines 234-241)

```bash
local prompt="Analyze this request and suggest 1-5 most relevant agents.

REQUEST: $request

AGENTS:
$agent_descriptions

Return ONLY comma-separated agent names (e.g., agent1,agent2) or NONE if unclear."
```

### Recommended Improved Prompt

```bash
local prompt="You are an expert agent dispatcher for a technical AI system. Your job is to analyze user requests and route them to the most appropriate specialized agents.

CRITICAL RULES:
1. **PROACTIVE Agents**: Agents marked with 'PROACTIVE' in their description MUST be suggested when their domain is mentioned
   - If request contains 'how does', 'best practices', 'documentation', 'research' → suggest research-analyst
   - If request mentions monitoring, observability, tracing, metrics, Datadog → suggest datadog-specialist
   - If request mentions tests, testing, QA, quality, coverage → suggest test-automator
   - If request mentions event sourcing, aggregates, projections, CQRS → suggest eventsourcing-expert

2. **Multi-Domain Requests**: Suggest 2-5 agents if request spans multiple domains
   - Example: 'API with tests' → backend-developer, test-automator
   - Example: 'PostgreSQL event sourcing' → postgres-pro, eventsourcing-expert

3. **Semantic Matching**: Match on meaning, not just exact keywords
   - 'observability', 'instrumentation', 'telemetry' → datadog-specialist
   - 'quality assurance', 'QA' → test-automator, qa-expert
   - 'database optimization', 'slow queries' → postgres-pro

4. **Return NONE**: Only if request is genuinely ambiguous or non-technical
   - Non-technical: 'weather', 'jokes', 'general questions'
   - Too vague without context: 'fix this', 'help' (< 3 words)

REQUEST: $request

AVAILABLE AGENTS:
$agent_descriptions

EXAMPLES OF GOOD MATCHES:
- 'optimize PostgreSQL query' → postgres-pro
- 'how does FastAPI async work' → research-analyst
- 'set up Datadog APM tracing' → datadog-specialist
- 'build REST API with tests and docs' → backend-developer,test-automator,documentation-engineer
- 'implement event sourcing aggregate' → eventsourcing-expert
- 'debug production error with traces' → debugger,datadog-specialist
- 'what is the weather' → NONE

OUTPUT FORMAT:
Return ONLY comma-separated agent names (e.g., agent1,agent2,agent3) or NONE.
No explanations, no extra text."
```

### Why This Improves Accuracy

1. **Explicit PROACTIVE Rules**: Reduces false negatives for auto-engage agents
2. **Multi-Domain Guidance**: Improves handling of complex requests
3. **Semantic Examples**: Teaches LLM to match synonyms and indirect references
4. **Clear NONE Criteria**: Reduces false positives for non-technical requests
5. **Example-Based Learning**: Shows LLM good vs bad matches

### Implementation Steps

1. Update hook at line 234-241 with new prompt
2. Test with sample requests:
   ```bash
   # Test PROACTIVE triggers
   CLAUDE_USER_MESSAGE="how does Django ORM work" ~/.claude/hooks/discover-agents.sh
   # Should suggest: research-analyst

   # Test multi-domain
   CLAUDE_USER_MESSAGE="build API with tests" ~/.claude/hooks/discover-agents.sh
   # Should suggest: backend-developer,test-automator

   # Test semantic matching
   CLAUDE_USER_MESSAGE="add observability to my app" ~/.claude/hooks/discover-agents.sh
   # Should suggest: datadog-specialist
   ```
3. Run full promptfoo evaluation:
   ```bash
   cd ~/.claude/promptfoo-tests
   ./run-tests.sh
   ./analyze-results.sh
   ```
4. Compare with baseline to measure improvement

## Priority 2: Enhance Agent Descriptions (MEDIUM IMPACT)

**Target**: Agent YAML frontmatter
**Expected Impact**: +10-15% accuracy improvement
**Effort**: Medium (update 24 agent files)

### Current Format

```yaml
description: Expert PostgreSQL specialist mastering database administration, performance optimization, and high availability
```

### Recommended Format

Add explicit trigger keywords at the start of descriptions:

```yaml
description: "PROACTIVE | TRIGGERS[postgres, postgresql, database, sql, query, index, migration, vacuum, replication] | Expert PostgreSQL specialist mastering database administration, performance optimization, and high availability"
```

### Examples by Agent

**datadog-specialist**:
```yaml
description: "PROACTIVE | TRIGGERS[datadog, monitoring, observability, apm, tracing, metrics, telemetry, instrumentation, logs, opentelemetry, statsd, dogstatsd, ddtrace] | Datadog and observability specialist - auto-engages for monitoring, distributed tracing, metrics collection, log aggregation. Validates via Context7 MCP and WebFetch."
```

**research-analyst**:
```yaml
description: "PROACTIVE | TRIGGERS[how does, how do, best practices, documentation, research, look up, fetch docs, api reference, library docs, framework guide] | Research analyst - auto-engages for documentation lookups, library/framework research, best practices discovery. Use WITHOUT waiting."
```

**test-automator**:
```yaml
description: "PROACTIVE | TRIGGERS[test, testing, qa, quality, coverage, pytest, unittest, integration test, e2e, test framework] | Test automation specialist - automatically engages for test automation, test frameworks, test coverage, CI/CD testing."
```

**eventsourcing-expert**:
```yaml
description: "PROACTIVE | TRIGGERS[event sourcing, aggregate, projection, domain event, cqrs, event store, eventsourcing library] | Expert in Python eventsourcing library. Use proactively for event sourcing patterns, aggregates, domain events, projections."
```

**postgres-pro**:
```yaml
description: "PROACTIVE | TRIGGERS[postgres, postgresql, database, sql, query, index, migration, vacuum, replication, pgbouncer, connection pool] | Expert PostgreSQL specialist mastering database administration, performance optimization, high availability."
```

### Implementation Steps

1. Create script to update all agent descriptions:
   ```bash
   # improvements/update-agent-descriptions.sh
   ```
2. Update each agent file with TRIGGERS[] section
3. Prioritize PROACTIVE agents first (highest impact)
4. Test LLM prompt understanding of new format
5. Re-run promptfoo evaluation

## Priority 3: Expand Keyword Patterns (MEDIUM IMPACT)

**Target**: Hook lines 158-213 (keyword matching logic)
**Expected Impact**: +15-20% accuracy improvement
**Effort**: Medium (add patterns to existing code)

### Missing Patterns (From Test Failures)

Add these patterns to keyword matching:

#### 1. Observability Synonyms (Line ~179)

**Current**:
```bash
if echo "$request_lower" | grep -qE "\blog\b|\bmonitor|\bobserv|metrics|telemetry|instrument|trace"; then
```

**Add**:
```bash
if echo "$request_lower" | grep -qE "\blog\b|\bmonitor|\bobserv|metrics|telemetry|instrument|trace|apm|distributed.?trac|opentelemetry|custom.?metrics|log.?aggreg"; then
    echo "$desc_lower" | grep -qE "log|monitor|observ|metrics|telemetry|datadog|tracing|apm" && matched=true
fi
```

#### 2. Quality Assurance Synonyms (Line ~169)

**Current**:
```bash
if echo "$request_lower" | grep -qE "\btest\b|\bqa\b|quality|coverage"; then
```

**Add**:
```bash
if echo "$request_lower" | grep -qE "\btest\b|\bqa\b|quality|coverage|quality.?assurance|test.?automation|test.?framework|integration.?test|e2e|end.?to.?end"; then
    echo "$desc_lower" | grep -qE "test|qa|quality|coverage|automation" && matched=true
fi
```

#### 3. Event Sourcing Patterns (Currently Missing!)

**Add new section around line 213**:
```bash
# Event Sourcing / CQRS
if echo "$request_lower" | grep -qE "event.?sourc|aggregate|projection|domain.?event|cqrs|event.?store"; then
    echo "$desc_lower" | grep -qE "event.?sourc|aggregate|projection|domain.?event|cqrs" && matched=true
fi
```

#### 4. Documentation Lookups (Expand Line ~199)

**Current**:
```bash
if echo "$request_lower" | grep -qE "research|documentation|\bhow does\b|\bhow do\b|look up|fetch docs|best practices|docs for|library.*docs|framework.*docs|api reference|\bfind docs\b|\bget docs\b"; then
```

**Add more patterns**:
```bash
if echo "$request_lower" | grep -qE "research|documentation|\bhow does\b|\bhow do\b|\bhow to\b|look up|fetch docs|best practices|docs for|library.*docs|framework.*docs|api reference|\bfind docs\b|\bget docs\b|what are.*best|guide for|tutorial for"; then
    echo "$desc_lower" | grep -qE "research|documentation|information gathering|best practices|comprehensive" && matched=true
fi
```

#### 5. Promptfoo Testing (Currently Missing!)

**Add new section**:
```bash
# Promptfoo / LLM Testing
if echo "$request_lower" | grep -qE "promptfoo|llm.?test|prompt.?eval|red.?team|ai.?quality"; then
    echo "$desc_lower" | grep -qE "promptfoo|llm.?test|prompt.?eval|red.?team" && matched=true
fi
```

### Implementation Steps

1. Create backup of current hook:
   ```bash
   cp ~/.claude/hooks/discover-agents.sh ~/.claude/hooks/discover-agents.sh.backup
   ```
2. Add new keyword patterns one category at a time
3. Test each addition:
   ```bash
   CLAUDE_USER_MESSAGE="add observability" ~/.claude/hooks/discover-agents.sh
   CLAUDE_USER_MESSAGE="quality assurance checks" ~/.claude/hooks/discover-agents.sh
   CLAUDE_USER_MESSAGE="implement aggregate" ~/.claude/hooks/discover-agents.sh
   ```
4. Run full evaluation after all changes
5. Measure improvement vs baseline

## Priority 4: Fix Ambiguity Detection (LOW-MEDIUM IMPACT)

**Target**: Hook lines 252-266 (is_ambiguous_request function)
**Expected Impact**: +5-10% accuracy improvement
**Effort**: Low

### Current Logic Issues

The ambiguity detection is too aggressive - it marks requests as ambiguous that have clear domain indicators.

**Current** (Line 253-266):
```bash
is_ambiguous_request() {
    local request="$1"
    local request_lower=$(echo "$request" | tr '[:upper:]' '[:lower:]')
    local word_count=$(echo "$request" | wc -w | tr -d ' ')

    [[ "$word_count" -lt 5 ]] && return 0  # Too broad!

    if echo "$request_lower" | grep -qE "^(check|improve|analyze|review|fix|help)" &&
       ! echo "$request_lower" | grep -qE "test|database|api|python|event|project|deploy|security|performance"; then
        return 0
    fi

    return 1
}
```

### Recommended Improvement

```bash
is_ambiguous_request() {
    local request="$1"
    local request_lower=$(echo "$request" | tr '[:upper:]' '[:lower:]')
    local word_count=$(echo "$request" | wc -w | tr -d ' ')

    # Very short requests (< 3 words) without domain keywords are ambiguous
    if [[ "$word_count" -lt 3 ]]; then
        # Check if it has domain keywords
        if ! echo "$request_lower" | grep -qE "postgres|database|test|api|monitor|datadog|event|k8s|kubernetes|aws|python|django"; then
            return 0  # Ambiguous
        fi
    fi

    # Vague action verbs without domain context
    if echo "$request_lower" | grep -qE "^(check|improve|analyze|review|fix|help|optimize|debug)(\s|$)" &&
       ! echo "$request_lower" | grep -qE "test|database|api|python|event|project|deploy|security|performance|monitor|trace|aggregate|query|kubernetes|postgres|datadog"; then
        return 0  # Ambiguous - vague verb without domain
    fi

    # Completely non-technical requests
    if echo "$request_lower" | grep -qE "weather|joke|meaning.?of.?life|tell.?me|what.?is.?the"; then
        return 0  # Ambiguous/non-technical
    fi

    return 1  # Not ambiguous - has domain context
}
```

### Why This Improves Accuracy

1. **Domain Keywords Override Length**: "test API" (2 words) is NOT ambiguous
2. **More Domain Patterns**: Adds missing triggers like monitor, trace, aggregate
3. **Non-Technical Detection**: Explicitly filters out jokes, weather, etc.
4. **Reduces False LLM Fallbacks**: More requests stay in fast keyword path

## Testing Improvements

After implementing each improvement:

### 1. Run Unit Tests

```bash
# Test specific scenarios
CLAUDE_USER_MESSAGE="optimize PostgreSQL query" ~/.claude/hooks/discover-agents.sh
# Expected: postgres-pro (keyword match)

CLAUDE_USER_MESSAGE="how does FastAPI work" ~/.claude/hooks/discover-agents.sh
# Expected: research-analyst (keyword match)

CLAUDE_USER_MESSAGE="add observability" ~/.claude/hooks/discover-agents.sh
# Expected: datadog-specialist (semantic match via LLM or keyword)
```

### 2. Run Full Promptfoo Evaluation

```bash
cd ~/.claude/promptfoo-tests
./run-tests.sh
./analyze-results.sh > reports/improved_v1.txt
```

### 3. Compare with Baseline

```bash
diff reports/baseline_*.txt reports/improved_v1.txt

# Or use compare script
./compare-strategies.sh
```

### 4. Measure Improvement

Track these metrics:
- **Overall Accuracy**: Target 80%+
- **Keyword Match Accuracy**: Should improve with expanded patterns
- **LLM Match Accuracy**: Should improve with better prompt
- **PROACTIVE Agent Coverage**: Should approach 100%
- **False Positive Rate**: Should decrease
- **False Negative Rate**: Should decrease

## Rollback Plan

If improvements degrade performance:

```bash
# Restore original hook
cp ~/.claude/hooks/discover-agents.sh.backup ~/.claude/hooks/discover-agents.sh

# Restore original agent descriptions (if changed)
git checkout ~/.claude/agents/*.md

# Re-run baseline
cd ~/.claude/promptfoo-tests
./establish-baseline.sh
```

## Iteration Strategy

1. **Week 1**: Implement Priority 1 (LLM prompt) - Expected: 50-60% accuracy
2. **Week 2**: Implement Priority 3 (keyword patterns) - Expected: 65-75% accuracy
3. **Week 3**: Implement Priority 2 (agent descriptions) - Expected: 75-85% accuracy
4. **Week 4**: Fine-tune and implement Priority 4 - Expected: 80%+ accuracy

Each week:
- Implement changes
- Run promptfoo evaluation
- Analyze results
- Adjust strategy based on data
- Document learnings

## Success Criteria

**Minimum (80% Target)**:
- ✅ Overall accuracy >= 80%
- ✅ PROACTIVE agent coverage >= 95%
- ✅ Clear domain requests >= 90% accuracy
- ✅ False positive rate < 10%

**Stretch (90% Target)**:
- ⭐ Overall accuracy >= 90%
- ⭐ PROACTIVE agent coverage = 100%
- ⭐ Multi-domain requests >= 85% accuracy
- ⭐ Keyword match accuracy >= 95%

## Long-Term Improvements

Beyond 80% accuracy:

1. **Machine Learning Enhancement**: Train custom classifier on agent matching
2. **User Feedback Loop**: Track which agents users actually invoke
3. **Context-Aware Matching**: Use conversation history for better suggestions
4. **Dynamic Learning**: Automatically improve patterns from user corrections
5. **A/B Testing**: Test multiple prompt variations in production

## Questions or Issues?

If improvements don't achieve target:
1. Review failed test cases in detail
2. Identify systematic failure patterns
3. Consider if test cases need adjustment
4. Consult with domain experts on agent boundaries
5. Re-evaluate PROACTIVE trigger criteria
