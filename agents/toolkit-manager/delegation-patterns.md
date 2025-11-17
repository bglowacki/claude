# Delegation Patterns

Guide to designing effective agent delegation and activation patterns.

## Delegation Types

### 1. Proactive Delegation
Agent automatically activates based on context without explicit user request.

**Characteristics:**
- Triggers on keywords or scenarios
- Auto-engages during workflow
- No explicit `@agent-name` needed
- Described with "Use proactively" in description

**Example:**
```yaml
description: |
  Reviews code quality and S.O.L.I.D principles.
  Use proactively after code changes or when reviewing PRs.
```

**Trigger Scenarios:**
- After file writes/edits
- When specific keywords appear
- During specific workflow phases
- Based on file types or patterns

### 2. On-Demand Delegation
Agent activates only when explicitly requested by user or main Claude.

**Characteristics:**
- Requires explicit invocation (`@agent-name`)
- User controls activation
- Described with "Delegate when" in description
- More predictable behavior

**Example:**
```yaml
description: |
  Generates OpenAPI schemas from Django REST Framework.
  Delegate when API endpoints change or schema validation needed.
```

**Trigger Scenarios:**
- User requests specific task
- Main Claude explicitly delegates
- Specific command or request pattern
- Complex task requiring specialist

### 3. Hybrid Delegation
Combines proactive and on-demand patterns.

**Characteristics:**
- Can auto-activate AND be manually invoked
- Flexible triggering
- Described with both "Use proactively" and "Delegate when"

**Example:**
```yaml
description: |
  Kubernetes deployment specialist managing manifests and GitOps.
  Use proactively for deployment topics. Delegate when infrastructure changes needed.
```

---

## Writing Effective Descriptions

### Structure Pattern

```
[What the agent does] [Domain/expertise focus].
[Proactive triggers]. [On-demand triggers].
```

### Examples of Good Descriptions

**Code Reviewer:**
```yaml
description: |
  Expert code reviewer validating S.O.L.I.D principles, security, and best practices.
  Use proactively after code changes. Delegate when reviewing PRs or ensuring code quality.
```

**Test Generator:**
```yaml
description: |
  Generates comprehensive pytest tests with fixtures and parametrization.
  Delegate when new features need tests or coverage is insufficient.
```

**Documentation Writer:**
```yaml
description: |
  Generates and maintains API documentation and OpenAPI schemas.
  Use proactively when API endpoints change. Delegate for documentation updates.
```

**Security Auditor:**
```yaml
description: |
  Reviews code for OWASP Top 10 vulnerabilities and security best practices.
  Use proactively before commits. Delegate when security review is requested.
```

**Infrastructure Manager:**
```yaml
description: |
  Kubernetes specialist managing deployments, services, and GitOps workflows.
  Use proactively for Kubernetes/Docker topics. Delegate for infrastructure work.
```

---

## Trigger Keywords

### Proactive Triggers

**Code Quality:**
- "refactor", "code review", "quality check", "cleanup"
- "S.O.L.I.D", "best practices", "patterns"

**Security:**
- "security", "vulnerability", "OWASP", "authentication", "authorization"
- "SQL injection", "XSS", "CSRF"

**Testing:**
- "test", "pytest", "coverage", "unit test", "integration test"
- "test suite", "test framework"

**Documentation:**
- "document", "docs", "README", "API docs", "OpenAPI"
- "schema", "specification"

**Infrastructure:**
- "deploy", "deployment", "Kubernetes", "Docker", "container"
- "manifest", "Helm", "Kustomize", "GitOps"

**Performance:**
- "optimize", "slow", "performance", "N+1", "query optimization"
- "caching", "profiling", "bottleneck"

**Event Sourcing:**
- "aggregate", "event", "projection", "event sourcing", "CQRS"
- "event store", "domain event"

### On-Demand Triggers

**Implementation:**
- User request for specific feature
- "implement X", "add feature Y", "create endpoint Z"

**Analysis:**
- "investigate", "analyze", "review", "audit"
- "what is", "how does", "explain"

**Generation:**
- "generate", "create", "scaffold", "setup"
- "initialize", "bootstrap"

**Research:**
- "research", "find", "compare", "evaluate"
- "best practices for", "options for"

---

## Multi-Agent Orchestration

### Sequential Delegation
One agent completes, then delegates to another.

**Pattern:**
```
architect-reviewer (design) → implementation → code-reviewer (quality)
```

**Description Pattern:**
```yaml
description: |
  [Task 1].
  Use proactively for [trigger 1].
  After completion, delegate to [next-agent] for [next step].
```

### Parallel Delegation
Multiple agents work simultaneously on independent tasks.

**Pattern:**
```
code-reviewer + documentation-engineer (both run in parallel after implementation)
```

**Description Pattern:**
```yaml
description: |
  [Task].
  Use proactively [trigger]. Can run in parallel with [other-agents].
```

### Conditional Delegation
Agent decides whether to delegate based on findings.

**Pattern:**
```
security-auditor → (if issues found) → debugger
```

**Description Pattern:**
```yaml
description: |
  [Task].
  Use proactively [trigger].
  Delegate to [specialist] if [condition detected].
```

---

## Context-Aware Triggers

### File Type Triggers

**Python Projects:**
```yaml
description: |
  Python expert specializing in type hints, async, and modern Python 3.11+.
  Use proactively when working with .py files.
```

**Django Projects:**
```yaml
description: |
  Django specialist for models, views, serializers, and DRF.
  Use proactively when working with Django files (models.py, views.py, serializers.py).
```

**Kubernetes Manifests:**
```yaml
description: |
  Kubernetes specialist for deployments, services, and manifests.
  Use proactively when working with YAML files in deployment/ directory.
```

### Workflow Phase Triggers

**Planning Phase:**
```yaml
description: |
  Architecture reviewer for system design and DDD patterns.
  Use proactively BEFORE implementation begins.
```

**Implementation Phase:**
```yaml
description: |
  Feature implementer for backend services.
  Delegate DURING implementation of new features.
```

**Quality Assurance Phase:**
```yaml
description: |
  Code reviewer and quality validator.
  Use proactively AFTER implementation completes.
```

**Deployment Phase:**
```yaml
description: |
  Infrastructure specialist for production deployments.
  Use proactively DURING deployment planning and execution.
```

---

## Anti-Patterns

### ❌ Vague Descriptions
```yaml
description: Helps with code stuff
```
**Problem:** No clear triggers, unclear when to use

✅ **Better:**
```yaml
description: |
  Reviews Python code for PEP 8 compliance and best practices.
  Use proactively after writing Python code.
```

### ❌ Too Broad Scope
```yaml
description: Does everything related to backend development
```
**Problem:** Overlaps with other agents, unclear responsibility

✅ **Better:**
```yaml
description: |
  Implements Django REST Framework API endpoints with serializers.
  Delegate when building RESTful APIs in Django projects.
```

### ❌ No Trigger Guidance
```yaml
description: Analyzes database queries
```
**Problem:** Missing when/how to activate

✅ **Better:**
```yaml
description: |
  Optimizes database queries for <100ms execution time.
  Use proactively when slow queries detected. Delegate for query optimization.
```

### ❌ Conflicting Triggers
```yaml
description: |
  Refactors code and writes tests.
```
**Problem:** Two distinct responsibilities, unclear primary purpose

✅ **Better (split into two agents):**
```yaml
# Agent 1
description: |
  Refactors code following S.O.L.I.D principles.
  Delegate when code needs structural improvement.

# Agent 2
description: |
  Generates comprehensive test suites.
  Delegate when tests are needed or coverage is low.
```

---

## Best Practices

### 1. Be Specific About Timing
```yaml
✅ Good: "Use proactively BEFORE implementation begins"
❌ Bad: "Use for planning"

✅ Good: "Use proactively AFTER code changes"
❌ Bad: "Use for reviews"
```

### 2. Include Clear Keywords
```yaml
✅ Good: "Use proactively for Kubernetes, Docker, container, deployment topics"
❌ Bad: "Use for infrastructure"
```

### 3. Differentiate Proactive vs On-Demand
```yaml
✅ Good: "Use proactively after edits. Delegate when review requested."
❌ Bad: "Use for code review"
```

### 4. Mention Related Agents
```yaml
✅ Good: "Use before implementation. After completion, code-reviewer validates quality."
❌ Bad: "Use for design"
```

### 5. Be Explicit About Scope
```yaml
✅ Good: "Django-specific model, view, and serializer implementation"
❌ Bad: "Backend development"
```

---

## Testing Delegation Patterns

### Validation Checklist

**Trigger Clarity:**
- [ ] Description states when to use (proactive/on-demand/hybrid)
- [ ] Trigger keywords are specific and unambiguous
- [ ] Workflow phase is clear (before/during/after)
- [ ] Related agents are mentioned if applicable

**Scope Definition:**
- [ ] Primary responsibility is clear
- [ ] No overlap with other agents (or overlap is intentional)
- [ ] Domain/expertise is well-defined
- [ ] Limitations are stated

**Activation Behavior:**
- [ ] Proactive agents auto-engage on correct triggers
- [ ] On-demand agents don't activate without explicit delegation
- [ ] Hybrid agents work in both modes
- [ ] No unintended activations

---

## Example: Complete Agent with Optimal Delegation

```yaml
---
name: eventsourcing-expert
description: |
  Expert in Python eventsourcing library for DDD and CQRS patterns.
  Use proactively when working with aggregates, domain events, projections, or eventsourcing library.
  Delegate when implementing event sourcing, designing aggregates, or creating projections.
tools: [Read, Write, Edit, Grep, Glob, Bash, WebFetch, mcp__context7__resolve-library-id, mcp__context7__get-library-docs]
color: purple
model: sonnet
---

# Purpose

Expert in Python eventsourcing library providing documentation-backed guidance for event sourcing implementations, aggregate design, and projection setup.

## Proactive Engagement Triggers

This agent automatically engages when conversation mentions:
- Aggregate, domain event, event store, projection, read model
- CQRS, event sourcing, eventsourcing library
- Implementing/creating/designing event-sourced components
- Event-driven architecture patterns

## On-Demand Triggers

Explicitly delegate when:
- User requests event sourcing implementation
- Designing new aggregates or domain events
- Creating or updating projections
- Troubleshooting eventsourcing issues
- Refactoring event-sourced code

## Instructions

[Detailed workflow steps...]

## Related Agents

**Before Implementation:**
- @architect-reviewer: Validates overall architecture and DDD patterns

**After Implementation:**
- @code-reviewer: Reviews code quality and best practices
- @test-automator: Generates tests for aggregates and projections

## Output Format

[Response structure...]
```

**Why this works:**
- ✅ Clearly states proactive triggers (auto-engages on keywords)
- ✅ Provides on-demand scenarios (explicit delegation)
- ✅ Mentions related agents for workflow orchestration
- ✅ Defines expertise scope clearly
- ✅ No ambiguity about when to activate

---

## Summary

| Pattern | Description Example | Trigger Style |
|---------|-------------------|--------------|
| **Proactive** | "Use proactively after code changes" | Auto-activates on keywords/events |
| **On-Demand** | "Delegate when feature implementation needed" | Requires explicit invocation |
| **Hybrid** | "Use proactively for X topics. Delegate when Y requested." | Both automatic and manual |

**Key Principles:**
1. Be explicit about proactive vs on-demand
2. Include specific trigger keywords
3. State workflow phase (before/during/after)
4. Define scope clearly to avoid overlap
5. Mention related agents for orchestration
6. Test activation behavior matches intent
