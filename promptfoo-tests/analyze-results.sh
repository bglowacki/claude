#!/bin/bash
# Analyze promptfoo evaluation results and generate accuracy report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RESULTS_FILE="results/evaluation.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Agent Discovery Hook - Results Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if results exist
if [ ! -f "$RESULTS_FILE" ]; then
    echo "❌ Results file not found: $RESULTS_FILE"
    echo ""
    echo "Run evaluation first:"
    echo "   promptfoo eval -o $RESULTS_FILE"
    echo ""
    exit 1
fi

echo "📁 Analyzing: $RESULTS_FILE"
echo ""

# Extract key metrics using jq
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not installed - install for detailed analysis"
    echo ""
    echo "Basic results summary:"
    cat "$RESULTS_FILE" | grep -E '"pass"|"score"|"reason"' | head -20
    exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 OVERALL METRICS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Calculate overall accuracy
TOTAL_TESTS=$(jq '.results | length' "$RESULTS_FILE")
PASSED_TESTS=$(jq '[.results[] | select(.pass == true)] | length' "$RESULTS_FILE")
FAILED_TESTS=$((TOTAL_TESTS - PASSED_TESTS))
ACCURACY=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)

echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Accuracy: ${ACCURACY}%"
echo ""

# Check if we hit 80% target
if (( $(echo "$ACCURACY >= 80" | bc -l) )); then
    echo "✅ TARGET MET: Accuracy >= 80%"
else
    echo "❌ TARGET MISSED: Accuracy < 80% (current: ${ACCURACY}%)"
    echo "   Gap to target: $(echo "scale=2; 80 - $ACCURACY" | bc)%"
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BREAKDOWN BY CATEGORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Analyze by test category
jq -r '.results[] | .vars.metadata.category' "$RESULTS_FILE" | sort | uniq | while read -r category; do
    if [ -n "$category" ] && [ "$category" != "null" ]; then
        total=$(jq "[.results[] | select(.vars.metadata.category == \"$category\")] | length" "$RESULTS_FILE")
        passed=$(jq "[.results[] | select(.vars.metadata.category == \"$category\" and .pass == true)] | length" "$RESULTS_FILE")
        accuracy=$(echo "scale=2; $passed * 100 / $total" | bc)
        echo "$category: $passed/$total (${accuracy}%)"
    fi
done

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ FAILURE ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show failed tests with reasons
jq -r '.results[] | select(.pass == false) |
    "Request: " + .vars.user_request +
    "\n  Expected: " + (.vars.expected_agents | join(", ")) +
    "\n  Got: " + .output +
    "\n  Reason: " + (.assertionResults[0].reason // "N/A") +
    "\n"' "$RESULTS_FILE"

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 FAILURE PATTERNS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count failure types
echo "False Positives (suggested wrong agents):"
jq '[.results[] | select(.pass == false) | .assertionResults[0].reason] |
    map(select(. != null and (. | contains("false positive") or contains("Invalid")))) |
    length' "$RESULTS_FILE"

echo ""
echo "False Negatives (missed correct agents):"
jq '[.results[] | select(.pass == false) | .assertionResults[0].reason] |
    map(select(. != null and (. | contains("Expected") and . | contains("but got NONE")))) |
    length' "$RESULTS_FILE"

echo ""
echo "PROACTIVE Agent Failures:"
jq '[.results[] | select(.pass == false) | .assertionResults[] | select(.type == "javascript" and (.reason | contains("PROACTIVE")))] |
    length' "$RESULTS_FILE"

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 RECOMMENDATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Generate recommendations based on failure patterns
echo "Based on failure analysis:"
echo ""

if (( $(echo "$ACCURACY < 80" | bc -l) )); then
    echo "1. IMPROVE LLM PROMPT:"
    echo "   - Add more specific instructions for agent selection"
    echo "   - Include examples of good matches"
    echo "   - Clarify PROACTIVE agent triggers"
    echo ""

    echo "2. ENHANCE AGENT DESCRIPTIONS:"
    echo "   - Make trigger keywords more prominent"
    echo "   - Add synonym coverage to descriptions"
    echo "   - Clarify domain boundaries"
    echo ""

    echo "3. EXPAND KEYWORD PATTERNS:"
    echo "   - Add missing trigger patterns to keyword matching"
    echo "   - Cover common synonyms and abbreviations"
    echo "   - Reduce reliance on LLM fallback"
    echo ""
fi

echo "4. NEXT STEPS:"
echo "   - Review failed test cases above"
echo "   - Implement recommended improvements"
echo "   - Re-run evaluation: ./run-tests.sh"
echo "   - Compare results with baseline"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Full Results: $RESULTS_FILE"
echo "🌐 Web View: promptfoo view"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
