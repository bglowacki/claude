# Feature Implementation Workflow

## Overview

Standard workflow for implementing new features with tests, documentation, and quality gates.

## Phases

### Phase 1: Planning
1. **Understand Requirements**: Clarify what needs to be built
2. **Break Down Work**: Use TodoWrite to create task list
3. **Identify Dependencies**: Determine what's sequential vs parallel
4. **Select Agents**: Match tasks to appropriate specialists

### Phase 2: Design (Optional for Complex Features)
1. **Architecture Review**: If significant changes, review design
2. **Pattern Selection**: Identify existing patterns to follow
3. **API Design**: If exposing new interfaces, design first

### Phase 3: Implementation
**Parallel where possible:**
- **Code Implementation**: Backend/frontend specialist
- **Test Planning**: test-automator or qa-expert

**Constraints:**
- Minimal necessary changes
- Follow existing patterns
- Single responsibility per change

### Phase 4: Quality Assurance
**Parallel execution:**
- **Code Review**: code-reviewer validates quality, security, patterns
- **Test Implementation**: test-automator writes comprehensive tests

**Sequential:**
1. Run tests - verify all pass
2. Check coverage - ensure threshold met

### Phase 5: Documentation & Deployment
**Parallel execution:**
- **Documentation**: documentation-engineer updates API docs
- **Deployment Config**: kubernetes-specialist or aws-cloud-specialist updates infrastructure

### Phase 6: Verification
**Final checks:**
1. All tests passing
2. Documentation updated
3. No security issues (code-reviewer)
4. Ready for PR/deployment

## Example Invocation

```
User: "Implement user authentication feature with JWT tokens"