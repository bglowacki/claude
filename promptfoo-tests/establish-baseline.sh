#!/bin/bash
# Establish baseline metrics for the current hook implementation
# Run this BEFORE making any improvements

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Establishing Baseline Metrics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create reports directory
mkdir -p reports

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BASELINE_FILE="reports/baseline_${TIMESTAMP}.txt"

echo "📁 Creating baseline report: $BASELINE_FILE"
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v promptfoo &> /dev/null; then
    echo "❌ promptfoo not installed"
    echo "   Install: npm install -g promptfoo"
    exit 1
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ ANTHROPIC_API_KEY not set"
    echo "   Set: export ANTHROPIC_API_KEY=your-key"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not installed - baseline report will be limited"
    echo "   Install: brew install jq"
fi

echo "✅ Prerequisites OK"
echo ""

# Run evaluation
echo "🚀 Running baseline evaluation..."
echo "   This may take 2-3 minutes..."
echo ""

promptfoo eval -c promptfoo.yaml -o results/baseline.json

echo ""
echo "✅ Evaluation complete"
echo ""

# Generate comprehensive baseline report
{
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "BASELINE EVALUATION REPORT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Timestamp: $(date)"
    echo "Hook Version: Current (pre-optimization)"
    echo "Test Suite: 55+ test scenarios"
    echo "Provider: Claude 3.5 Haiku"
    echo ""

    if command -v jq &> /dev/null; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "OVERALL METRICS"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        TOTAL=$(jq '.results | length' results/baseline.json)
        PASSED=$(jq '[.results[] | select(.pass == true)] | length' results/baseline.json)
        FAILED=$((TOTAL - PASSED))
        ACCURACY=$(echo "scale=2; $PASSED * 100 / $TOTAL" | bc)

        echo "Total Tests: $TOTAL"
        echo "Passed: $PASSED"
        echo "Failed: $FAILED"
        echo "Accuracy: ${ACCURACY}%"
        echo ""

        if (( $(echo "$ACCURACY >= 80" | bc -l) )); then
            echo "✅ Already meets 80% target!"
        else
            GAP=$(echo "scale=2; 80 - $ACCURACY" | bc)
            echo "❌ Below 80% target"
            echo "   Gap: ${GAP}%"
            echo "   Tests needed to improve: $(echo "scale=0; $TOTAL * $GAP / 100" | bc)"
        fi

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "BREAKDOWN BY CATEGORY"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        jq -r '.results[] | .vars.metadata.category' results/baseline.json | sort | uniq | while read -r category; do
            if [ -n "$category" ] && [ "$category" != "null" ]; then
                total=$(jq "[.results[] | select(.vars.metadata.category == \"$category\")] | length" results/baseline.json)
                passed=$(jq "[.results[] | select(.vars.metadata.category == \"$category\" and .pass == true)] | length" results/baseline.json)
                accuracy=$(echo "scale=2; $passed * 100 / $total" | bc)
                printf "%-30s %3s/%3s (%5s%%)\n" "$category" "$passed" "$total" "$accuracy"
            fi
        done
    else
        echo "Install jq for detailed metrics: brew install jq"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "FILES GENERATED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Results JSON: results/baseline.json"
    echo "Baseline Report: $BASELINE_FILE"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "NEXT STEPS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1. Review failure analysis:"
    echo "   ./analyze-results.sh"
    echo ""
    echo "2. Compare keyword vs LLM strategies:"
    echo "   ./compare-strategies.sh"
    echo ""
    echo "3. Review recommendations in:"
    echo "   improvements/RECOMMENDATIONS.md"
    echo ""
    echo "4. Implement improvements and re-run:"
    echo "   ./run-tests.sh"
    echo ""
    echo "5. Compare with baseline:"
    echo "   diff $BASELINE_FILE reports/improved_v1.txt"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

} | tee "$BASELINE_FILE"

echo ""
echo "✅ Baseline established: $BASELINE_FILE"
echo ""
echo "📊 For detailed analysis, run:"
echo "   ./analyze-results.sh"
echo "   ./compare-strategies.sh"
