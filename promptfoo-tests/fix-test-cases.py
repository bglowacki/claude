#!/usr/bin/env python3
"""
Fix test-cases.yaml structure to move expected_agents into vars section
This makes expected_agents accessible to promptfoo assertions
"""

import yaml
import sys

def fix_test_cases(input_file, output_file):
    """Restructure test cases to move expected_agents into vars"""

    # Load with safe_load to handle multi-document YAML
    with open(input_file, 'r') as f:
        content = f.read()

    # Parse YAML
    try:
        test_cases = yaml.safe_load(content)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        sys.exit(1)

    if not isinstance(test_cases, list):
        print("Error: Expected a list of test cases")
        sys.exit(1)

    # Fix each test case
    fixed_count = 0
    for test_case in test_cases:
        # Check if expected_agents exists at root level
        if 'expected_agents' in test_case:
            # Move it into vars
            if 'vars' not in test_case:
                test_case['vars'] = {}

            test_case['vars']['expected_agents'] = test_case['expected_agents']
            del test_case['expected_agents']
            fixed_count += 1

        # Also move priority into vars if it exists at root
        if 'priority' in test_case:
            if 'vars' not in test_case:
                test_case['vars'] = {}

            test_case['vars']['priority'] = test_case['priority']
            del test_case['priority']

    # Write fixed YAML
    with open(output_file, 'w') as f:
        # Add header comment
        f.write("# Comprehensive Agent Discovery Test Cases\n")
        f.write("# Testing both keyword matching and LLM matching strategies\n")
        f.write("# Expected accuracy target: 80%+\n")
        f.write("# \n")
        f.write("# Structure: expected_agents is now in vars for promptfoo assertions\n\n")

        # Write YAML with proper formatting
        yaml.dump(test_cases, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

    print(f"✅ Fixed {fixed_count} test cases")
    print(f"✅ Output written to: {output_file}")

    return fixed_count

if __name__ == "__main__":
    input_file = "test-cases.yaml"
    output_file = "test-cases-fixed.yaml"

    print(f"📝 Restructuring test cases...")
    print(f"   Input: {input_file}")
    print(f"   Output: {output_file}")
    print()

    fixed_count = fix_test_cases(input_file, output_file)

    if fixed_count > 0:
        print()
        print("🎯 Next steps:")
        print("   1. Review: cat test-cases-fixed.yaml | head -50")
        print("   2. Backup: cp test-cases.yaml test-cases-original.yaml")
        print("   3. Replace: mv test-cases-fixed.yaml test-cases.yaml")
        print("   4. Test: promptfoo eval -c promptfoo.yaml")
