#!/bin/bash
# Compare Keyword Matching vs LLM Matching Performance
# Analyzes which strategy performs better for different test categories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RESULTS_FILE="results/evaluation.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚖️  Keyword Matching vs LLM Matching - Performance Comparison"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "$RESULTS_FILE" ]; then
    echo "❌ Results file not found: $RESULTS_FILE"
    echo "   Run: promptfoo eval -o $RESULTS_FILE"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is required for this analysis"
    echo "   Install: brew install jq"
    exit 1
fi

echo "📊 STRATEGY PERFORMANCE COMPARISON"
echo ""

# Analyze tests expecting keyword strategy
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 KEYWORD MATCHING STRATEGY (Expected)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

KEYWORD_TOTAL=$(jq '[.results[] | select(.vars.metadata.expected_strategy == "keyword")] | length' "$RESULTS_FILE")
KEYWORD_PASSED=$(jq '[.results[] | select(.vars.metadata.expected_strategy == "keyword" and .pass == true)] | length' "$RESULTS_FILE")
KEYWORD_ACCURACY=$(echo "scale=2; $KEYWORD_PASSED * 100 / $KEYWORD_TOTAL" | bc)

echo "Total Tests: $KEYWORD_TOTAL"
echo "Passed: $KEYWORD_PASSED"
echo "Failed: $((KEYWORD_TOTAL - KEYWORD_PASSED))"
echo "Accuracy: ${KEYWORD_ACCURACY}%"
echo ""

# Show keyword strategy failures
echo "Keyword Strategy Failures:"
jq -r '.results[] |
    select(.vars.metadata.expected_strategy == "keyword" and .pass == false) |
    "  - " + .vars.user_request + "\n    Expected: " + (.vars.expected_agents | join(", ")) + "\n    Got: " + .output + "\n"' \
    "$RESULTS_FILE" | head -20

echo ""

# Analyze tests expecting LLM strategy
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 LLM MATCHING STRATEGY (Expected)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LLM_TOTAL=$(jq '[.results[] | select(.vars.metadata.expected_strategy == "llm")] | length' "$RESULTS_FILE")
LLM_PASSED=$(jq '[.results[] | select(.vars.metadata.expected_strategy == "llm" and .pass == true)] | length' "$RESULTS_FILE")
LLM_ACCURACY=$(echo "scale=2; $LLM_PASSED * 100 / $LLM_TOTAL" | bc)

echo "Total Tests: $LLM_TOTAL"
echo "Passed: $LLM_PASSED"
echo "Failed: $((LLM_TOTAL - LLM_PASSED))"
echo "Accuracy: ${LLM_ACCURACY}%"
echo ""

echo "LLM Strategy Failures:"
jq -r '.results[] |
    select(.vars.metadata.expected_strategy == "llm" and .pass == false) |
    "  - " + .vars.user_request + "\n    Expected: " + (.vars.expected_agents | join(", ")) + "\n    Got: " + .output + "\n"' \
    "$RESULTS_FILE" | head -20

echo ""

# Compare strategies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 STRATEGY COMPARISON"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
printf "%-25s %10s %10s %10s\n" "Strategy" "Total" "Passed" "Accuracy"
printf "%-25s %10s %10s %10s\n" "--------" "-----" "------" "--------"
printf "%-25s %10s %10s %9s%%\n" "Keyword Matching" "$KEYWORD_TOTAL" "$KEYWORD_PASSED" "$KEYWORD_ACCURACY"
printf "%-25s %10s %10s %9s%%\n" "LLM Matching" "$LLM_TOTAL" "$LLM_PASSED" "$LLM_ACCURACY"
echo ""

# Determine better strategy
if (( $(echo "$KEYWORD_ACCURACY > $LLM_ACCURACY" | bc -l) )); then
    DIFF=$(echo "scale=2; $KEYWORD_ACCURACY - $LLM_ACCURACY" | bc)
    echo "✅ Keyword matching performs better by ${DIFF}%"
    echo ""
    echo "💡 Recommendation: Expand keyword patterns to reduce LLM fallback reliance"
elif (( $(echo "$LLM_ACCURACY > $KEYWORD_ACCURACY" | bc -l) )); then
    DIFF=$(echo "scale=2; $LLM_ACCURACY - $KEYWORD_ACCURACY" | bc)
    echo "✅ LLM matching performs better by ${DIFF}%"
    echo ""
    echo "💡 Recommendation: Focus on improving LLM prompt quality"
else
    echo "⚖️  Both strategies perform equally"
fi

echo ""

# Analyze mixed strategy tests (keyword expected but might use LLM)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 STRATEGY FALLBACK ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# These tests expected keyword but might have fallen back to LLM
# Check for tests that are ambiguous (< 5 words) but expected keyword match

AMBIGUOUS_KEYWORD=$(jq '[.results[] |
    select(.vars.metadata.expected_strategy == "keyword") |
    select((.vars.user_request | split(" ") | length) < 5)] |
    length' "$RESULTS_FILE")

echo "Tests expecting keyword match but potentially ambiguous: $AMBIGUOUS_KEYWORD"
echo ""

if [ "$AMBIGUOUS_KEYWORD" -gt 0 ]; then
    echo "These tests might fallback to LLM despite expecting keyword match:"
    jq -r '.results[] |
        select(.vars.metadata.expected_strategy == "keyword") |
        select((.vars.user_request | split(" ") | length) < 5) |
        "  - \"" + .vars.user_request + "\" (" + ((.vars.user_request | split(" ") | length) | tostring) + " words)"' \
        "$RESULTS_FILE"
    echo ""
    echo "💡 These should have strong keyword triggers to avoid LLM fallback"
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 OPTIMIZATION RECOMMENDATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if (( $(echo "$KEYWORD_ACCURACY < 80" | bc -l) )); then
    echo "1. IMPROVE KEYWORD PATTERNS:"
    echo "   - Add missing domain keywords from failing tests"
    echo "   - Cover synonyms and abbreviations"
    echo "   - Review failed keyword tests above for missing patterns"
    echo ""
fi

if (( $(echo "$LLM_ACCURACY < 80" | bc -l) )); then
    echo "2. IMPROVE LLM PROMPT:"
    echo "   - Add examples of good agent matches"
    echo "   - Clarify PROACTIVE agent auto-engagement rules"
    echo "   - Improve agent description formatting for better matching"
    echo ""
fi

echo "3. REDUCE LLM FALLBACK RELIANCE:"
echo "   - Current LLM fallback: triggered for ambiguous requests (< 5 words)"
echo "   - Goal: Keyword patterns should handle 80%+ of clear domain requests"
echo "   - Minimize expensive LLM calls for fast matching"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
