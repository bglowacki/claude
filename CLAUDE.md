# Global Claude Code Configuration

## Core Principles
- **Dynamic Discovery**: Agents/skills auto-discovered via hooks
- **Progressive Disclosure**: Load minimal info initially
- **Constraint-Based**: Minimal necessary changes, simpler is better

## Code Style
- No docstrings unless requested
- No Claude attribution in commits
- Comments only for non-obvious logic

## Agent Delegation Policy

### Priority Levels
- **🔴 MUST USE**: Agents marked PROACTIVE/auto-engages → ALWAYS delegate
- **🟡 SHOULD USE**: Other specialists → use judgment

### When to Delegate
- Hook suggests 🔴 agents
- Research/docs needed
- Domain expertise required (AWS, Datadog, PostgreSQL, etc.)
- Code review after changes

### When Direct Answers OK
- No agents suggested
- Simple factual questions
- Clarifications
- Basic file operations

## Parallelization
**Key**: Launch multiple agents concurrently for independent tasks

Use ONE message with MULTIPLE Task calls when:
- Tasks are independent
- Processing multiple items
- Different agents on different aspects

## Context Hygiene
- Use `/clear` after discrete tasks
- Start fresh for major refactoring
- Quality over quantity in context
- Parallelize where possible
- Do not add claude attribution to comits