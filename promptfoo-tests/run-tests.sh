#!/bin/bash
# Agent Discovery Hook - Promptfoo Evaluation Script
# Runs comprehensive testing of LLM matching logic

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Agent Discovery Hook - LLM Matching Evaluation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if promptfoo is installed
if ! command -v promptfoo &> /dev/null; then
    echo "❌ promptfoo is not installed"
    echo ""
    echo "Install with: npm install -g promptfoo"
    echo "Or: npx promptfoo@latest eval"
    exit 1
fi

# Check for API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ ANTHROPIC_API_KEY environment variable is not set"
    echo ""
    echo "Set with: export ANTHROPIC_API_KEY=your-key-here"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""
echo "📋 Test Configuration:"
echo "   - Config: promptfoo.yaml"
echo "   - Test Cases: test-cases.yaml"
echo "   - Provider: Claude 3.5 Haiku"
echo "   - Total Tests: $(grep -c '^- description:' test-cases.yaml)"
echo ""
echo "🚀 Running evaluation..."
echo ""

# Run promptfoo evaluation
promptfoo eval -c promptfoo.yaml

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Evaluation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 View detailed results:"
echo "   1. Web UI: promptfoo view"
echo "   2. JSON export: promptfoo eval -o results/evaluation.json"
echo "   3. Analysis script: ./analyze-results.sh"
echo ""
