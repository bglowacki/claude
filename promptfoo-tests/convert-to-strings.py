#!/usr/bin/env python3
"""
Convert expected_agents from array format to comma-separated string format
Workaround for promptfoo YAML array parsing issue
"""

import yaml

def convert_to_strings(input_file, output_file):
    """Convert all expected_agents arrays to comma-separated strings"""

    with open(input_file, 'r') as f:
        test_cases = yaml.safe_load(f)

    converted = 0
    for test_case in test_cases:
        if 'vars' in test_case and 'expected_agents' in test_case['vars']:
            expected = test_case['vars']['expected_agents']

            # Convert array to comma-separated string
            if isinstance(expected, list):
                test_case['vars']['expected_agents'] = ','.join(expected)
                converted += 1
            elif not isinstance(expected, str):
                # Handle other types
                test_case['vars']['expected_agents'] = str(expected)
                converted += 1

    # Write with proper formatting
    with open(output_file, 'w') as f:
        f.write("# Comprehensive Agent Discovery Test Cases\n")
        f.write("# Expected agents stored as comma-separated strings\n")
        f.write("# (Workaround for promptfoo YAML array parsing)\n\n")
        yaml.dump(test_cases, f, default_flow_style=False, sort_keys=False)

    print(f"✅ Converted {converted} test cases to string format")
    print(f"✅ Output: {output_file}")

if __name__ == "__main__":
    convert_to_strings("test-cases.yaml", "test-cases-strings.yaml")
    print("\n🎯 Next steps:")
    print("   mv test-cases-strings.yaml test-cases.yaml")
    print("   # Update promptfoo.yaml to use: tests: file://test-cases.yaml")
    print("   promptfoo eval -c promptfoo.yaml")
