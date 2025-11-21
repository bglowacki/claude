# Promptfoo Testing Framework - Quick Start Guide

Get started testing the agent discovery hook in 5 minutes.

## Installation (One-Time Setup)

```bash
# Install promptfoo globally
npm install -g promptfoo

# OR use without installation
npx promptfoo@latest --version

# Set your API key
export ANTHROPIC_API_KEY="your-api-key-here"

# Add to shell profile for persistence
echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.zshrc  # or ~/.bashrc
```

## Quick Start (3 Commands)

```bash
# Navigate to test directory
cd ~/.claude/promptfoo-tests

# 1. Establish baseline (current accuracy: ~20%)
./establish-baseline.sh

# 2. Analyze failures
./analyze-results.sh

# 3. Compare strategies
./compare-strategies.sh
```

## What Gets Created

```
~/.claude/promptfoo-tests/
├── results/
│   └── baseline.json         # Evaluation results
├── reports/
│   └── baseline_*.txt        # Baseline report with timestamp
└── .promptfoo/               # Promptfoo cache (auto-generated)
```

## Understanding the Output

### Baseline Report Shows:

**Overall Metrics**:
```
Total Tests: 55
Passed: 11
Failed: 44
Accuracy: 20.00%
```

**Category Breakdown**:
```
clear-domain                 5/10  (50.00%)
ambiguous-short             3/6   (50.00%)
multi-domain                0/4   (0.00%)
proactive-research          0/5   (0.00%)
...
```

**Target Gap**:
```
❌ Below 80% target
   Gap: 60.00%
   Tests needed to improve: ~33 tests
```

## Next Steps After Baseline

### 1. Review Failures

```bash
./analyze-results.sh
```

Look for:
- **False Negatives**: Expected agents not suggested (most common)
- **False Positives**: Wrong agents suggested
- **PROACTIVE Failures**: Auto-engage agents missed

### 2. Identify Patterns

```bash
./compare-strategies.sh
```

Shows:
- Keyword matching accuracy vs LLM matching
- Which strategy performs better
- Tests falling back to LLM unexpectedly

### 3. Implement Improvements

See `improvements/RECOMMENDATIONS.md` for specific changes:

**Priority 1 (Highest Impact)**: Improve LLM prompt
- Update hook lines 234-241
- Expected: +30-40% accuracy

**Priority 2**: Expand keyword patterns
- Add missing triggers to hook lines 158-213
- Expected: +15-20% accuracy

**Priority 3**: Enhance agent descriptions
- Add TRIGGERS[] to agent YAML frontmatter
- Expected: +10-15% accuracy

### 4. Re-Run Evaluation

```bash
# After implementing improvements
./run-tests.sh

# Generate new report
./analyze-results.sh > reports/improved_v1.txt

# Compare with baseline
diff reports/baseline_*.txt reports/improved_v1.txt
```

### 5. Iterate Until 80%+

Repeat steps 1-4 until accuracy >= 80%

## Common Commands

```bash
# Full evaluation
promptfoo eval

# View in web UI (interactive)
promptfoo view

# Export results to JSON
promptfoo eval -o results/custom-name.json

# Clear cache and re-run
rm -rf .promptfoo/cache
promptfoo eval

# Run specific test cases (filter)
# Edit promptfoo.yaml to comment out unwanted tests
```

## Troubleshooting

### "promptfoo: command not found"

```bash
# Install globally
npm install -g promptfoo

# Or use npx
npx promptfoo@latest eval
```

### "ANTHROPIC_API_KEY is not set"

```bash
export ANTHROPIC_API_KEY="your-key-here"

# Verify
echo $ANTHROPIC_API_KEY
```

### "jq: command not found"

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq

# Scripts work without jq but provide limited output
```

### Tests running very slow

```bash
# Increase concurrency in promptfoo.yaml
evaluateOptions:
  maxConcurrency: 20  # Default: 10

# Enable caching (enabled by default)
evaluateOptions:
  cache: true
```

### Results don't match expected

```bash
# Check test case expectations
cat test-cases.yaml

# Review agent descriptions used in prompt
grep "description:" ~/.claude/agents/*.md

# Verify hook logic
cat ~/.claude/hooks/discover-agents.sh | grep -A 20 "llm_match_agents"
```

## Cost Estimate

- **Per test run**: ~$0.10 (55 tests × Claude Haiku)
- **With caching**: ~$0.02 (only re-runs changed tests)
- **Weekly testing**: ~$0.50
- **Full optimization cycle**: ~$2-5

## Tips for Best Results

1. **Run baseline first** - Establishes starting point
2. **Implement one change at a time** - Easier to measure impact
3. **Use caching** - Speeds up iterations (enabled by default)
4. **Review failures manually** - Automated metrics don't tell full story
5. **Test improvements incrementally** - Don't wait to implement all changes
6. **Document what works** - Add notes to reports/
7. **Compare versions** - Keep baseline for reference

## Files Reference

| File | Purpose |
|------|---------|
| `promptfoo.yaml` | Main configuration - tests LLM matching prompt |
| `test-cases.yaml` | 55+ test scenarios with ground truth |
| `run-tests.sh` | Quick evaluation runner |
| `analyze-results.sh` | Detailed failure analysis |
| `compare-strategies.sh` | Keyword vs LLM performance comparison |
| `establish-baseline.sh` | One-time baseline setup |
| `improvements/RECOMMENDATIONS.md` | Specific improvement suggestions |
| `README.md` | Full documentation |

## Success Criteria

**Minimum Target** (80%):
- Overall accuracy >= 80%
- PROACTIVE coverage >= 95%
- False positive rate < 10%

**Stretch Target** (90%):
- Overall accuracy >= 90%
- PROACTIVE coverage = 100%
- Multi-domain accuracy >= 85%

## Get Help

1. Read full docs: `README.md`
2. Review recommendations: `improvements/RECOMMENDATIONS.md`
3. Check test cases: `test-cases.yaml`
4. Inspect configuration: `promptfoo.yaml`
5. View web UI: `promptfoo view`

## Summary Workflow

```
┌─────────────────────────┐
│ Install promptfoo      │
│ Set ANTHROPIC_API_KEY  │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ ./establish-baseline.sh│  ← Run once
│ (Creates baseline)     │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ ./analyze-results.sh   │  ← Identify failures
│ ./compare-strategies.sh│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Implement improvements │  ← See RECOMMENDATIONS.md
│ (LLM prompt, keywords) │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ ./run-tests.sh         │  ← Re-evaluate
│ Compare with baseline  │
└───────────┬─────────────┘
            │
            ▼
        Accuracy >= 80%?
            │
        ┌───┴───┐
        │       │
       Yes      No
        │       │
        ▼       └──► Iterate (go back to analyze)
    Success!
```

Ready? Start here:

```bash
cd ~/.claude/promptfoo-tests
./establish-baseline.sh
```
