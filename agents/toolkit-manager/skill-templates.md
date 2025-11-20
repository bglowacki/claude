# Skill Templates

Ready-to-use templates for common skill types.

## Basic Implementation Skill

```yaml
---
name: [Feature Name] Implementation
description: |
  Implements [specific feature] following [project conventions/framework].
  Use this when: user requests [feature type] or needs to [specific task].
---

# Instructions

## Prerequisites
- [Required knowledge or setup]
- [Dependencies or tools needed]

## Workflow
1. **Analyze Requirements**: Understand what needs to be implemented
2. **Design Solution**: Plan the implementation approach
3. **Implement**: Write the code following project conventions
4. **Test**: Create and run tests to verify functionality
5. **Document**: Update relevant documentation

## Best Practices
- [Key practice 1]
- [Key practice 2]

# Examples

## Example 1: [Basic Scenario]
**User Request**: "[Example request]"

**Actions Taken**:
1. [Action 1]
2. [Action 2]

**Expected Outcome**: [What should happen]
```

## Analysis/Research Skill

```yaml
---
name: [Domain] Analysis
description: |
  Analyzes [specific aspect] to provide insights and recommendations.
  Use this when: user needs to understand [topic] or investigate [issue type].
allowed-tools: [Read, Grep, Glob]  # Read-only for safety
---

# Instructions

## Prerequisites
- Access to relevant codebase/documentation
- Understanding of [domain concepts]

## Workflow
1. **Gather Information**: Collect relevant data using read-only tools
2. **Analyze Patterns**: Identify trends, issues, or opportunities
3. **Generate Insights**: Synthesize findings into actionable recommendations
4. **Present Findings**: Deliver clear, structured analysis

## Analysis Framework
- [What to look for]
- [How to evaluate]
- [Reporting structure]

# Examples

## Example 1: [Analysis Scenario]
**User Request**: "[Example question]"

**Actions Taken**:
1. Searched for [pattern] using Grep
2. Analyzed [aspect] across [scope]
3. Identified [findings]

**Expected Outcome**: Clear report with recommendations
```

## Code Review Skill

```yaml
---
name: [Aspect] Code Review
description: |
  Reviews code for [specific quality aspect] following [standards].
  Use this when: code changes are made or user requests [aspect] review.
allowed-tools: [Read, Grep, Glob]  # Read-only
---

# Instructions

## Prerequisites
- Understanding of [quality standards]
- Knowledge of [common anti-patterns]

## Workflow
1. **Scan Code**: Identify files/areas to review
2. **Check Against Standards**: Evaluate against [criteria]
3. **Document Issues**: List problems with severity levels
4. **Suggest Improvements**: Provide actionable fixes
5. **Verify Compliance**: Confirm standards are met

## Review Checklist
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

# Examples

## Example 1: [Review Type]
**User Request**: "Review [component] for [aspect]"

**Actions Taken**:
1. Analyzed [area] for [issues]
2. Found [number] violations of [standard]
3. Provided fixes for each issue

**Expected Outcome**: Code meets quality standards
```

## Testing Skill

```yaml
---
name: [Framework] Test Generator
description: |
  Generates comprehensive tests using [testing framework] for [code type].
  Use this when: new code is written or user requests test coverage.
---

# Instructions

## Prerequisites
- [Testing framework] installed and configured
- Understanding of [test patterns]

## Workflow
1. **Analyze Code**: Understand what needs testing
2. **Identify Scenarios**: Determine test cases (positive, negative, edge)
3. **Generate Tests**: Write tests following [framework] patterns
4. **Run Tests**: Verify all tests pass
5. **Check Coverage**: Ensure adequate coverage metrics

## Test Structure
- **Unit Tests**: Test individual functions/classes
- **Integration Tests**: Test component interactions
- **Edge Cases**: Test boundary conditions

# Examples

## Example 1: [Test Type]
**User Request**: "Generate tests for [component]"

**Actions Taken**:
1. Analyzed [component] functionality
2. Created [number] test scenarios
3. Generated [framework] tests
4. Verified 100% coverage

**Expected Outcome**: Comprehensive test suite with passing tests
```

## Deployment/Infrastructure Skill

```yaml
---
name: [Platform] Deployment
description: |
  Manages deployment to [platform] following [practices].
  Use this when: deploying new services or updating [infrastructure].
---

# Instructions

## Prerequisites
- Access to [platform/tools]
- Understanding of [deployment concepts]

## Workflow
1. **Prepare Configuration**: Set up deployment manifests
2. **Validate Settings**: Check environment variables, secrets
3. **Deploy**: Apply changes to [environment]
4. **Verify**: Confirm successful deployment
5. **Monitor**: Check health and logs

## Safety Checks
- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

# Examples

## Example 1: [Deployment Scenario]
**User Request**: "Deploy [service] to [environment]"

**Actions Taken**:
1. Created [manifest type]
2. Configured [settings]
3. Applied to [environment]
4. Verified [health checks]

**Expected Outcome**: Service running successfully
```

## Documentation Skill

```yaml
---
name: [Documentation Type] Generator
description: |
  Generates and maintains [doc type] following [standards].
  Use this when: code/API changes or user requests documentation updates.
---

# Instructions

## Prerequisites
- Understanding of [documentation format]
- Access to code/API definitions

## Workflow
1. **Analyze Changes**: Identify what needs documentation
2. **Generate Content**: Create/update documentation
3. **Validate Format**: Ensure compliance with [standard]
4. **Update References**: Fix cross-references and links
5. **Verify Accuracy**: Check documentation matches implementation

## Documentation Standards
- [Standard 1]
- [Standard 2]

# Examples

## Example 1: [Doc Update Scenario]
**User Request**: "Update docs for [new feature]"

**Actions Taken**:
1. Analyzed [feature] implementation
2. Generated [doc type]
3. Validated against [schema]
4. Updated cross-references

**Expected Outcome**: Accurate, up-to-date documentation
```

## Refactoring Skill

```yaml
---
name: [Pattern] Refactoring
description: |
  Refactors code to follow [pattern/principle] without changing behavior.
  Use this when: code needs improvement or user requests refactoring.
---

# Instructions

## Prerequisites
- Existing test suite (to verify no behavior changes)
- Understanding of [pattern/principle]

## Workflow
1. **Analyze Current State**: Understand existing implementation
2. **Plan Refactoring**: Design improved structure
3. **Refactor Incrementally**: Make small, safe changes
4. **Run Tests**: Verify behavior unchanged after each step
5. **Verify Improvement**: Confirm code quality improved

## Refactoring Patterns
- [Pattern 1]: When to use, how to apply
- [Pattern 2]: When to use, how to apply

# Examples

## Example 1: [Refactoring Type]
**User Request**: "Refactor [component] to use [pattern]"

**Actions Taken**:
1. Analyzed current [structure]
2. Applied [pattern] incrementally
3. Ran tests after each change
4. Verified [improvement metric]

**Expected Outcome**: Cleaner code with same behavior
```

---

## Choosing the Right Template

| Skill Purpose | Template to Use | Key Characteristics |
|---------------|----------------|---------------------|
| Build new features | Implementation | Full tool access, creates files |
| Investigate issues | Analysis/Research | Read-only, generates insights |
| Check code quality | Code Review | Read-only, provides feedback |
| Add test coverage | Testing | Writes test files, runs tests |
| Infrastructure work | Deployment | Platform-specific, safety checks |
| Update docs | Documentation | Generates/updates doc files |
| Improve code structure | Refactoring | Incremental, test-verified |

## Customization Tips

1. **Replace placeholders**: Change `[Feature Name]`, `[Domain]`, etc. to your specific use case
2. **Adjust tool restrictions**: Add `allowed-tools` for analysis skills, remove for implementation
3. **Expand examples**: Add more examples for complex skills, fewer for simple ones
4. **Add supporting files**: Reference additional docs for detailed guidance
5. **Tailor workflow**: Modify steps to match your project's conventions

## Template Validation Checklist

Before using a template, verify:
- [ ] All placeholders replaced with actual values
- [ ] Description includes clear trigger conditions
- [ ] Tool restrictions match skill purpose
- [ ] Examples are relevant and realistic
- [ ] Workflow steps are actionable
- [ ] Prerequisites are complete
