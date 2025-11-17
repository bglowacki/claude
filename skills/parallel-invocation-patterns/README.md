# Parallel Invocation Patterns Skill

Guides users in creating or enhancing project instructions with parallel invocation best practices for efficient agent and skill usage.

## Purpose

This skill helps you document parallel execution patterns in your project's instruction files (instructions.md, CLAUDE.md, .claude/instructions.md, etc.) so that Claude Code can efficiently execute multiple agents concurrently.

## Files in This Skill

### SKILL.md (Main Skill)
The complete guide for creating parallel invocation documentation:
- Step-by-step workflow for adding parallel patterns to project instructions
- Decision frameworks for parallel vs sequential execution
- Best practices and key principles
- Project-specific customization guidance
- 4 detailed examples showing different project types

### template-snippets.md (Supporting Reference)
Ready-to-use templates you can copy directly:
- Complete instructions template
- Section templates (batch operations, decision framework, examples)
- Domain-specific templates (API, microservices, Django, React, monorepo)
- Anti-pattern templates
- Customization checklist

### README.md (This File)
Overview and quick reference

## When to Use This Skill

Use this skill when you want to:
- Create project instructions for a new project
- Enhance existing instructions with parallel execution patterns
- Standardize parallel invocation documentation across multiple projects
- Help your team understand when and how to parallelize agent invocations

## Quick Start

1. **Invoke the skill**: Ask Claude to help you using this skill:
   ```
   @parallel-invocation-patterns help me add parallel patterns to my project instructions
   ```

2. **Choose your approach**:
   - New project: Use the complete template from `template-snippets.md`
   - Existing project: Add individual sections to existing instructions
   - Multiple projects: Create a base template and customize per project

3. **Customize for your project**:
   - Replace placeholder examples with real scenarios
   - Add your actual file paths and agent names
   - Document your project-specific constraints
   - Include 3+ concrete examples from your codebase

## Key Concepts

### Parallel Execution
Multiple agents running simultaneously by invoking them in a single message with multiple Task tool calls.

**Benefits**: Faster completion, efficient resource usage, better user experience

### Sequential Execution
Agents running one after another when dependencies exist or order matters.

**When required**: Dependencies between tasks, migration steps, risk of conflicts

### Decision Framework
The skill provides clear criteria for when to parallelize vs when to sequence:
- Independent tasks → Parallel
- Dependencies → Sequential
- File conflicts → Sequential
- Batch operations → Parallel (usually)

## Complementary Tools

This skill works with:
- **toolkit-manager**: Creates agents/skills; this skill documents how to use them
- **workflow-orchestrator**: Plans complex workflows; this skill teaches general patterns
- **Your project agents**: Whatever specialized agents you have in your project

## Examples Included

The skill includes examples for:
1. Django API project with 20+ endpoints
2. Microservices project with 15 services
3. Multi-project template standardization
4. Monorepo with package dependencies

Each example shows:
- Project context
- User request
- Actions taken
- Expected outcome

## Common Use Cases

### Use Case 1: API Project
Document how to parallelize endpoint security reviews, documentation updates, and test generation.

### Use Case 2: Microservices
Document service-level parallelization while respecting deployment dependencies.

### Use Case 3: Monorepo
Document package-level parallelization while respecting dependency graph.

### Use Case 4: Frontend Components
Document component analysis and test generation in parallel.

## Anti-Patterns Documented

The skill helps you document common mistakes:
1. Sequential batch operations (should be parallel)
2. Over-orchestration (simple tasks don't need workflow-orchestrator)
3. Ignoring dependencies (causes failures)

## Maintenance

Update your project instructions when:
- New agents/skills are added
- New parallel patterns are discovered
- Team identifies confusion or gaps
- Project constraints change

Review quarterly or after major changes.

## Tips for Success

1. **Be Specific**: Use real project examples, not abstract rules
2. **Show Don't Tell**: One good example beats paragraphs of explanation
3. **Document Why**: Explain benefits and constraints, not just procedures
4. **Keep It Actionable**: Instructions should be concrete enough to follow
5. **Evolve With Usage**: Update based on real team feedback

## Getting Help

If you need help using this skill:
1. Read through SKILL.md for the complete workflow
2. Check template-snippets.md for ready-to-use templates
3. Ask Claude to help you: `@parallel-invocation-patterns [your question]`

## Version History

- **v1.0** (2025-11-17): Initial creation with comprehensive templates and examples
