# Parallel Invocation Patterns

## Overview

Parallel invocation is the practice of launching multiple Claude Code agents concurrently to work on independent tasks simultaneously. This dramatically improves throughput and reduces total completion time.

## Core Principle

**ONE message with MULTIPLE Task tool calls** - This is the key to parallel execution.

## When to Use

### Independent Tasks
- Tasks have no dependencies on each other
- Each task can proceed without waiting for others
- No risk of conflicts (e.g., editing same files)

### High-Value Scenarios
1. **Batch Operations**: Processing multiple similar items
2. **Multi-Domain Review**: Different specialists analyzing different aspects
3. **Implementation + Testing**: Developer and test-automator working simultaneously
4. **Multi-Component Updates**: Different agents handling different components

## How to Invoke

### Correct Pattern
```
User: "Analyze all agents for best practices"