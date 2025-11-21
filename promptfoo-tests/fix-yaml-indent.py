#!/usr/bin/env python3
"""
Fix YAML indentation for expected_agents arrays
PyYAML writes lists in compact format which some parsers misinterpret
"""

import re

def fix_yaml_indentation(input_file, output_file):
    """Fix indentation of YAML lists to ensure they're parsed as arrays"""

    with open(input_file, 'r') as f:
        content = f.read()

    # Fix pattern: expected_agents followed by unindented list items
    # Replace:
    #   expected_agents:
    #   - agent1
    # With:
    #   expected_agents:
    #     - agent1

    # Pattern: find expected_agents: followed by newline and list items
    def fix_list_indent(match):
        key = match.group(1)
        items = match.group(2)

        # Add 2 spaces to each list item line
        fixed_items = '\n'.join(f'  {line}' if line.strip().startswith('-') else line
                                for line in items.split('\n'))

        return f'{key}\n{fixed_items}'

    # Fix expected_agents lists
    content = re.sub(
        r'(    expected_agents:)\n((?:    - [^\n]+\n?)+)',
        fix_list_indent,
        content
    )

    with open(output_file, 'w') as f:
        f.write(content)

    print(f"✅ Fixed YAML indentation")
    print(f"✅ Output: {output_file}")

if __name__ == "__main__":
    input_file = "test-cases-updated.yaml"
    output_file = "test-cases-fixed-indent.yaml"

    fix_yaml_indentation(input_file, output_file)

    print("\n🎯 Next steps:")
    print("   1. Review: head -20 test-cases-fixed-indent.yaml")
    print("   2. Replace: mv test-cases-fixed-indent.yaml test-cases.yaml")
    print("   3. Test: promptfoo eval -c promptfoo.yaml")
