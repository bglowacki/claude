# Agent Discovery Hook - Promptfoo Testing Framework

Comprehensive testing infrastructure for the agent discovery hook's LLM matching logic. This framework validates agent selection accuracy and provides actionable recommendations for improvements.

## Overview

**Current Performance**: ~20% accuracy (informal testing)
**Target**: 80%+ accuracy
**Test Coverage**: 55+ diverse test scenarios

### What This Tests

The hook uses two strategies for agent matching:
1. **Keyword Matching** (lines 146-221) - Fast pattern-based matching
2. **LLM Matching** (lines 224-250) - Fallback for ambiguous requests

This framework primarily tests the **LLM matching prompt** to optimize its accuracy.

## Quick Start

### Prerequisites

```bash
# Install promptfoo
npm install -g promptfoo

# Or use npx (no installation required)
npx promptfoo@latest --version

# Set API key
export ANTHROPIC_API_KEY="your-api-key-here"
```

### Run Evaluation

```bash
cd ~/.claude/promptfoo-tests

# Run full evaluation
./run-tests.sh

# Or use promptfoo directly
promptfoo eval

# View results in web UI
promptfoo view
```

### Analyze Results

```bash
# Generate detailed analysis report
./analyze-results.sh

# Export results to JSON
promptfoo eval -o results/evaluation.json
```

## Test Suite Structure

### Test Categories (55+ tests)

1. **Clear Domain-Specific Requests** (10 tests)
   - PostgreSQL optimization → `postgres-pro`
   - Datadog tracing → `datadog-specialist`
   - Event sourcing → `eventsourcing-expert`
   - Expected Strategy: Keyword matching

2. **Ambiguous Short Requests** (6 tests)
   - "fix this", "help", "check this code"
   - Expected Strategy: LLM matching
   - Tests handling of vague inputs

3. **Multi-Domain Requests** (4 tests)
   - API + tests + docs → Multiple agents
   - Database + event sourcing → `postgres-pro`, `eventsourcing-expert`
   - Tests capability to suggest 2-5 relevant agents

4. **PROACTIVE Agent Triggers** (5 tests)
   - "how does X work" → `research-analyst`
   - "best practices for Y" → `research-analyst`
   - Tests auto-engagement patterns

5. **Edge Cases** (6 tests)
   - Synonyms: observability, instrumentation, QA
   - Indirect references: "queries taking too long"
   - Tests semantic understanding

6. **Typos and Abbreviations** (3 tests)
   - "postgres" vs "postgresql"
   - "k8s" → `kubernetes-specialist`
   - Tests robustness

7. **Complex Scenarios** (3 tests)
   - Debug + monitoring, migration + testing
   - Tests multi-faceted requests

8. **Framework-Specific** (2 tests)
   - Django, FastAPI requests
   - Tests framework recognition

9. **Debugging** (3 tests)
   - Error debugging, test failures, bottlenecks
   - Tests troubleshooting detection

10. **Documentation & Review** (2 tests)
    - Code review, API documentation
    - Tests meta-activities

11. **Metrics & Telemetry** (3 tests)
    - Custom metrics, logs, OpenTelemetry
    - Tests observability patterns

12. **Event Sourcing Patterns** (3 tests)
    - Projections, domain events, CQRS
    - Tests specialized pattern recognition

13. **Negative Tests** (3 tests)
    - "weather today", "tell me a joke"
    - Should return NONE
    - Tests false positive avoidance

## Configuration Files

### `promptfoo.yaml`

Main configuration testing the LLM prompt from the hook:

```yaml
description: "Agent Discovery Hook - LLM Matching Evaluation"

providers:
  - anthropic:claude-3-5-haiku-20241022  # Matches production hook

prompts:
  - id: agent-matcher-v1
    prompt: |
      Analyze this request and suggest 1-5 most relevant agents.
      REQUEST: {{user_request}}
      AGENTS: [full agent list with descriptions]
      Return ONLY comma-separated agent names or NONE if unclear.

tests: file://test-cases.yaml

defaultTest:
  assert:
    - Format validation (agent names or NONE)
    - Agent name validation (only real agents)
    - Ground truth matching (precision/recall/F1)
    - PROACTIVE agent validation
```

### `test-cases.yaml`

55+ test scenarios with:
- `user_request`: The input prompt
- `expected_agents`: Ground truth agent names
- `priority`: MUST/SHOULD/NONE
- `metadata.category`: Test category
- `metadata.expected_strategy`: keyword/llm/none

### Assertion Logic

**4-Layer Validation**:

1. **Structural Validation**
   - Output is "NONE" OR comma-separated agent names
   - 1-5 agents suggested (not more)
   - No extra text or invalid characters

2. **Agent Name Validation**
   - All suggested agents exist in roster
   - No hallucinated agent names
   - Prevents false positives

3. **Ground Truth Matching**
   - Calculates Precision, Recall, F1 score
   - Pass threshold: F1 >= 0.7
   - Allows flexibility for multi-agent scenarios
   - Provides detailed reason with metrics

4. **PROACTIVE Agent Validation**
   - Checks if PROACTIVE agents are suggested when triggered
   - Validates auto-engagement patterns
   - Ensures critical agents aren't missed

## Evaluation Metrics

### Primary Metrics

- **Accuracy**: Percentage of tests passed (target: 80%+)
- **F1 Score**: Harmonic mean of precision and recall (per test)
- **Precision**: Correct suggestions / total suggestions
- **Recall**: Correct suggestions / expected suggestions

### Secondary Metrics

- **Category Accuracy**: Breakdown by test category
- **False Positive Rate**: Wrong agents suggested
- **False Negative Rate**: Correct agents missed
- **PROACTIVE Coverage**: PROACTIVE agents correctly triggered

## Current Baseline

Run initial evaluation to establish baseline:

```bash
./run-tests.sh
./analyze-results.sh > baseline-report.txt
```

Expected baseline results:
- **Overall Accuracy**: ~20% (matches informal testing)
- **Failure Patterns**:
  - High false negative rate (missing PROACTIVE agents)
  - Low recall on multi-domain requests
  - Poor synonym/indirect reference handling

## Improvement Workflow

### 1. Run Baseline Evaluation

```bash
./run-tests.sh
./analyze-results.sh > reports/baseline.txt
```

### 2. Analyze Failure Patterns

Review `analyze-results.sh` output:
- Which categories have lowest accuracy?
- Are failures due to false positives or false negatives?
- Are PROACTIVE agents being missed?
- Is prompt ambiguity the issue?

### 3. Implement Improvements

**Option A: Improve LLM Prompt** (lines 234-241 in hook)
- Add examples of good matches
- Clarify PROACTIVE agent triggers
- Improve agent description formatting
- Add explicit instructions for multi-domain requests

**Option B: Enhance Keyword Patterns** (lines 146-221 in hook)
- Add missing trigger keywords
- Cover synonyms and abbreviations
- Reduce reliance on LLM fallback

**Option C: Improve Agent Descriptions** (agent YAML files)
- Make trigger keywords more prominent
- Add synonym coverage
- Clarify domain boundaries

### 4. Test Improvements

```bash
# Update hook or test cases
# Re-run evaluation
./run-tests.sh

# Compare with baseline
./analyze-results.sh > reports/improved-v1.txt
diff reports/baseline.txt reports/improved-v1.txt
```

### 5. Iterate Until 80%+

Repeat steps 2-4 until accuracy target is met.

## Recommended Improvements

Based on initial analysis, prioritize these changes:

### High Impact: Improve LLM Prompt

**Current prompt** (hook line 234-241):
```
Analyze this request and suggest 1-5 most relevant agents.

REQUEST: $request

AGENTS:
$agent_descriptions

Return ONLY comma-separated agent names (e.g., agent1,agent2) or NONE if unclear.
```

**Improved prompt** (proposed):
```
You are an expert agent dispatcher. Analyze the user's request and suggest 1-5 most relevant agents.

CRITICAL RULES:
1. PROACTIVE agents (marked in descriptions) MUST be suggested when their triggers match
2. For ambiguous requests without clear domain, return NONE
3. For multi-domain requests, suggest up to 5 agents
4. Match on semantics, not just keywords (e.g., "observability" → datadog-specialist)

REQUEST: $request

AGENTS:
$agent_descriptions

EXAMPLES:
- "optimize PostgreSQL query" → postgres-pro
- "how does FastAPI work" → research-analyst (PROACTIVE for "how does")
- "set up monitoring" → datadog-specialist (PROACTIVE for monitoring)
- "build API with tests" → backend-developer,test-automator

Return ONLY comma-separated agent names or NONE.
```

### Medium Impact: Enhance Agent Descriptions

Make trigger keywords more prominent:

**Before**:
```yaml
description: Expert PostgreSQL specialist mastering database administration...
```

**After**:
```yaml
description: TRIGGERS[postgres, postgresql, database, sql, query, index, migration] - Expert PostgreSQL specialist mastering database administration...
```

### Low Impact: Expand Keyword Patterns

Add missing patterns to keyword matching:
- "observability" → datadog-specialist
- "instrumentation" → datadog-specialist
- "quality assurance" → qa-expert, test-automator

## Cost Estimation

Running the full test suite:

- **Test count**: 55 tests
- **Provider**: Claude 3.5 Haiku
- **Input tokens per test**: ~1,500 (agent descriptions + prompt)
- **Output tokens per test**: ~20 (agent names)
- **Total tokens**: ~83,000 input + 1,100 output
- **Estimated cost**: ~$0.10 per full run (Haiku pricing)

**Recommendation**: Use caching (enabled by default) to reduce costs on repeated runs.

## Troubleshooting

### promptfoo not found

```bash
# Install globally
npm install -g promptfoo

# Or use npx
npx promptfoo@latest eval
```

### ANTHROPIC_API_KEY not set

```bash
export ANTHROPIC_API_KEY="your-key-here"

# Or add to ~/.bashrc or ~/.zshrc
echo 'export ANTHROPIC_API_KEY="your-key-here"' >> ~/.bashrc
```

### jq not installed (for analysis)

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

### Tests failing with "Invalid agent names"

Check that `promptfoo.yaml` agent list matches current roster:

```bash
# Get current agent list
ls ~/.claude/agents/*.md | xargs -I {} basename {} .md

# Update promptfoo.yaml if agents were added/removed
```

## Integration with Hook

After achieving 80%+ accuracy, integrate improvements back to the hook:

1. **Update LLM prompt** (hook lines 234-241)
2. **Add missing keyword patterns** (hook lines 146-221)
3. **Update agent descriptions** (agent YAML frontmatter)
4. **Add regression testing** to CI/CD

## Next Steps

1. ✅ Run baseline evaluation: `./run-tests.sh`
2. ✅ Generate baseline report: `./analyze-results.sh > reports/baseline.txt`
3. ⬜ Implement priority improvements (LLM prompt)
4. ⬜ Re-run evaluation and compare
5. ⬜ Iterate until 80%+ accuracy
6. ⬜ Update hook with improvements
7. ⬜ Add regression tests to prevent accuracy degradation

## Files

```
promptfoo-tests/
├── README.md              # This file
├── promptfoo.yaml         # Main promptfoo configuration
├── test-cases.yaml        # 55+ test scenarios
├── run-tests.sh          # Evaluation runner
├── analyze-results.sh    # Results analysis script
└── results/              # Evaluation outputs (generated)
    └── evaluation.json
```

## References

- **Hook Implementation**: `~/.claude/hooks/discover-agents.sh`
- **Agent Roster**: `~/.claude/agents/*.md`
- **Promptfoo Docs**: https://www.promptfoo.dev/docs/
- **Assertion Types**: https://www.promptfoo.dev/docs/configuration/expected-outputs/
