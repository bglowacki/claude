# Ready-to-Use Template Snippets

This file contains copy-paste templates for adding parallel invocation patterns to your project instructions.

## Complete Instructions Template

Use this as a starting point for new project instructions:

```markdown
# Claude Code Project Instructions

## Batch Operations Pattern

When handling requests involving multiple items (keywords: "all", "multiple", "every"):

### Standard Approach for Simple Batch Operations

1. **Identify Items**: Use Glob/Grep to discover all items
2. **Select Agent**: Determine which specialized agent handles each item
3. **Parallel Invocation**: Launch multiple Task tool calls in a SINGLE message
4. **Aggregate Results**: Collect and summarize findings

### Example Pattern

**User request**: "[CUSTOMIZE: insert your project scenario]"

**Correct approach**:
1. Use Glob to find items: `[CUSTOMIZE: your project path pattern]`
2. Identify [CUSTOMIZE: agent-name] as the appropriate agent
3. Launch multiple Task invocations in ONE message (all parallel)
4. Aggregate results and report patterns

## Parallel Task Invocation Best Practices

**Key principle**: To invoke multiple agents in parallel, make multiple Task tool calls in a **single response message**.

### Benefits
- All agents run simultaneously (not sequential)
- Faster completion time
- Efficient resource usage
- Better user experience

### When to Parallelize
- Tasks are independent (no dependencies between them)
- Same agent type processing different items
- Different agents working on different aspects
- [CUSTOMIZE: add project-specific criteria]

### When NOT to Parallelize
- Tasks have dependencies (one needs output from another)
- Sequential execution required by nature of work
- Risk of conflicts (e.g., editing same file)
- [CUSTOMIZE: add project-specific constraints]

## Decision Framework: Parallel vs Sequential

### Use PARALLEL execution when:
- ✅ Tasks are independent (no shared state)
- ✅ Order doesn't matter (commutative operations)
- ✅ No file conflicts (different files or read-only)
- ✅ Same operation on multiple items

### Use SEQUENTIAL execution when:
- ❌ Tasks have dependencies (A needs B's output)
- ❌ Order matters (migration steps, deployment phases)
- ❌ Risk of conflicts (editing same file)
- ❌ Resource constraints (database locks, API rate limits)

## Project-Specific Examples

### Example 1: [CUSTOMIZE: Scenario Name]

**User request**: "[CUSTOMIZE: actual request]"

**Parallelization opportunity**: [CUSTOMIZE: explain why parallel]

**Execution pattern**:
1. [CUSTOMIZE: step 1]
2. [CUSTOMIZE: step 2 - invoke agents in parallel]
3. [CUSTOMIZE: step 3]

**Agents used**: [CUSTOMIZE: @agent-name-1, @agent-name-2]

**Expected outcome**: [CUSTOMIZE: what should result]

## Common Anti-Patterns to Avoid

### Anti-Pattern 1: Sequential Batch Operations
**Wrong**: Process items one at a time, waiting for each result

**Right**: Process all items simultaneously in single message

### Anti-Pattern 2: Over-Orchestration
**Wrong**: Delegate simple batch operations to workflow-orchestrator

**Right**: Use workflow-orchestrator only for complex multi-phase workflows with 3+ different agents

## Agent Selection Guidelines

[CUSTOMIZE: List your project's available agents and their use cases]

- **[agent-name]**: [what it does]
- **[agent-name]**: [what it does]
```

## Section Templates

### Batch Operations (Minimal)

```markdown
## Batch Operations Pattern

When processing multiple items:
1. Identify items with Glob/Grep
2. Select appropriate agent
3. Invoke agent multiple times in SINGLE message (parallel)
4. Aggregate results

**Example**: "[YOUR_SCENARIO]"
- Find: `[YOUR_PATH_PATTERN]`
- Agent: @[YOUR_AGENT]
- Execute: Multiple parallel Task invocations
- Result: Aggregated report
```

### Parallel Best Practices (Minimal)

```markdown
## Parallel Task Invocation

**Key**: Multiple Task calls in ONE message = parallel execution

**Parallelize when**:
- Independent tasks
- No dependencies
- No file conflicts

**Sequential when**:
- Dependencies exist
- Order matters
- Risk of conflicts
```

### Decision Framework (Minimal)

```markdown
## Parallel vs Sequential

**Parallel**: ✅ Independent | ✅ No conflicts | ✅ Order doesn't matter

**Sequential**: ❌ Dependencies | ❌ Order matters | ❌ Conflicts possible
```

### Example Template (Detailed)

```markdown
### Example: [Scenario Name]

**User request**: "[What user might ask]"

**Context**: [Brief explanation of the scenario]

**Parallelization strategy**:
- **What runs in parallel**: [List items]
- **Why it's safe**: [Explain independence]
- **Agents used**: [@agent-1, @agent-2, @agent-3]

**Execution pattern**:
1. [Preparation step]
2. **Parallel invocation**: Launch @[agent] for each [item] simultaneously
3. [Aggregation step]

**Expected outcome**: [What should result]

**Anti-pattern to avoid**: [Common mistake for this scenario]
```

### Example Template (Minimal)

```markdown
### Example: [Scenario]

**Request**: "[user request]"
**Pattern**: @[agent] invoked N times in parallel
**Outcome**: [result]
```

## Domain-Specific Templates

### Web API / REST API Project

```markdown
## API Parallel Patterns

### Pattern 1: Endpoint Security Review
**Request**: "Review all API endpoints for security issues"
**Execution**:
1. `Glob: src/api/endpoints/**/*.py` (or your pattern)
2. Parallel: @security-auditor for each endpoint file
3. Aggregate: Combined security report

### Pattern 2: API Documentation Update
**Request**: "Update OpenAPI docs for all endpoints"
**Execution**:
1. `Grep: @api_view decorator` to find endpoints
2. Parallel: @documentation-engineer for each endpoint
3. Aggregate: Updated openapi.yaml

### Constraints
- ⚠️ API schema changes must be sequential (versioning)
- ✅ Individual endpoint implementations can be parallel
- ✅ Endpoint tests can be analyzed in parallel
```

### Microservices Project

```markdown
## Microservices Parallel Patterns

### Pattern 1: Service Health Check
**Request**: "Check deployment readiness for all services"
**Execution**:
1. `Glob: services/*/` to find services
2. Parallel: @kubernetes-specialist for each service manifest
3. Aggregate: Deployment readiness report

### Pattern 2: Cross-Service Analysis
**Request**: "Analyze service boundaries and dependencies"
**Execution**:
1. Map service dependency graph
2. Parallel: @architect-reviewer for each service (within same level)
3. Sequential: Review each dependency level (respect order)
4. Aggregate: Architecture assessment

### Constraints
- ⚠️ Database migrations across services must be sequential
- ⚠️ Deployment rollouts must respect dependency order
- ✅ Service-level testing can be parallel
- ✅ Independent services can be developed in parallel
```

### Django Project

```markdown
## Django Parallel Patterns

### Pattern 1: Model Review
**Request**: "Review all Django models for best practices"
**Execution**:
1. `Glob: */models.py` or `Grep: class.*models.Model`
2. Parallel: @django-developer or @code-reviewer for each model file
3. Aggregate: Model quality report

### Pattern 2: Migration Safety Check
**Request**: "Check all pending migrations for safety"
**Execution**:
1. `Bash: python manage.py showmigrations --plan`
2. Sequential: @django-developer reviews each migration in order
3. Aggregate: Migration safety report

### Constraints
- ⚠️ Migrations MUST be sequential (Django enforces order)
- ✅ Model files can be reviewed in parallel
- ✅ View/serializer files can be analyzed in parallel
- ✅ Test files can be processed in parallel
```

### React / Frontend Project

```markdown
## Frontend Parallel Patterns

### Pattern 1: Component Security Audit
**Request**: "Audit all components for XSS vulnerabilities"
**Execution**:
1. `Glob: src/components/**/*.tsx`
2. Parallel: @security-auditor for each component
3. Aggregate: Security findings report

### Pattern 2: Component Test Coverage
**Request**: "Generate tests for all components"
**Execution**:
1. `Glob: src/components/**/*.tsx`
2. Parallel: @test-automator for each component
3. Aggregate: Test coverage report

### Constraints
- ✅ Components can be analyzed/tested in parallel (isolated)
- ✅ Utility functions can be processed in parallel
- ⚠️ Global state changes require careful coordination
- ⚠️ Build steps may need to be sequential
```

### Monorepo Project

```markdown
## Monorepo Parallel Patterns

### Pattern 1: Package Analysis
**Request**: "Analyze all packages for code quality"
**Execution**:
1. `Glob: packages/*/` to find packages
2. Check dependency graph
3. Parallel: @code-reviewer for independent packages
4. Sequential: Review dependent packages in dependency order
5. Aggregate: Per-package quality reports

### Pattern 2: Cross-Package Refactoring
**Request**: "Refactor shared utility across packages"
**Execution**:
1. Identify affected packages (dependency graph)
2. Sequential: Update packages in reverse dependency order
3. Parallel: Update tests for each package
4. Aggregate: Verification report

### Constraints
- ⚠️ Respect package dependency order for changes
- ✅ Independent packages can be developed in parallel
- ✅ Tests within packages can run in parallel
- ⚠️ Shared tooling changes may need sequential rollout

### Decision Tree
```
Same package?
  → Yes: Parallel (if different files)
  → No: Check dependency graph
    → Independent packages: Parallel
    → Dependent packages: Sequential (dep order)
```
```

## Anti-Pattern Templates

### Anti-Pattern 1: Sequential Batch Processing

```markdown
## ❌ Anti-Pattern: Sequential Batch Processing

**What it looks like**:
User: "Analyze all [items]"
Claude: Analyzes item 1, waits... Analyzes item 2, waits... (repeated N times)

**Why it's wrong**:
- Wastes time (sequential instead of parallel)
- Poor user experience (slow)
- Doesn't leverage Claude's parallel capabilities

**Correct approach**:
Claude: Identifies all items → Launches N parallel Task invocations in SINGLE message → Aggregates results

**Example**:
- ❌ Wrong: Process 10 files one at a time = 10× time
- ✅ Right: Process 10 files in parallel = 1× time
```

### Anti-Pattern 2: Over-Orchestration

```markdown
## ❌ Anti-Pattern: Over-Orchestration

**What it looks like**:
User: "Analyze all [simple items]"
Claude: Delegates to @workflow-orchestrator → Creates complex multi-phase plan → Over-engineers simple task

**Why it's wrong**:
- Adds unnecessary complexity
- Workflow orchestrator is for complex multi-phase workflows
- Simple batch operations don't need orchestration

**Correct approach**:
- Use @workflow-orchestrator ONLY for: 3+ different agents, sequential dependencies, complex workflows
- Handle simple batch ops directly with parallel Task invocations

**Examples**:
- ❌ Wrong: "Analyze all agents" → workflow-orchestrator (over-engineering)
- ✅ Right: "Analyze all agents" → Parallel @toolkit-manager invocations
- ✅ Use orchestrator: "Implement auth + tests + docs + deploy" (complex, multi-phase)
```

### Anti-Pattern 3: Ignoring Dependencies

```markdown
## ❌ Anti-Pattern: Ignoring Dependencies

**What it looks like**:
User: "Update [dependent items]"
Claude: Processes all items in parallel, ignoring dependency order → Breaks dependencies

**Why it's wrong**:
- Violates dependency constraints
- Can cause build/runtime failures
- Data corruption in database migrations

**Correct approach**:
- Analyze dependencies FIRST
- Group by dependency levels
- Sequential processing respecting dependency order
- Parallel only within same dependency level

**Example**:
- ❌ Wrong: Parallel database migrations (breaks order)
- ✅ Right: Sequential migrations (respects dependencies)
- ✅ Right: Parallel model reviews (no dependencies)
```

## Customization Checklist

When using these templates, customize:

- [ ] Replace `[CUSTOMIZE: ...]` markers with actual content
- [ ] Add your project's file paths and patterns
- [ ] List your project's available agents
- [ ] Include 3+ project-specific examples
- [ ] Document your project's specific constraints
- [ ] Add anti-patterns common in your domain
- [ ] Reference actual filenames/paths from your codebase
- [ ] Include real user request examples from your team
- [ ] Add decision criteria specific to your architecture
- [ ] Document resource constraints (databases, APIs, etc.)

## Quick Start Guide

### 1. Choose Your Template
- **New project**: Use "Complete Instructions Template"
- **Existing instructions**: Use individual section templates
- **Domain-specific**: Use domain template (API, microservices, etc.)

### 2. Customize Core Sections
- Batch Operations Pattern (with your example)
- Parallel Best Practices (with your constraints)
- Decision Framework (with your criteria)

### 3. Add Examples
- Start with 3 examples
- Use real project paths
- Reference actual agents
- Show anti-patterns

### 4. Document Constraints
- Sequential requirements (migrations, deployments)
- Parallel opportunities (tests, reviews)
- Resource limits (databases, APIs)
- Project-specific rules

### 5. Validate
- Follow instructions yourself
- Get team feedback
- Iterate based on usage
- Keep updated

---

**Tips**:
- Start minimal, expand based on needs
- Real examples > abstract rules
- Update as project evolves
- Make it actionable, not theoretical
