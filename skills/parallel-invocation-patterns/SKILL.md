---
name: Parallel Invocation Patterns for Project Instructions
description: Guides users in creating or enhancing project instructions (instructions.md, CLAUDE.md, etc.) with parallel invocation best practices for efficient agent and skill usage. Use this when user wants to add parallel execution patterns to project instructions, create instructions for a new project, or standardize parallel invocation documentation across multiple projects.
allowed-tools: [Read, Write, Edit, Grep, Glob]
---

# Instructions

## Purpose

This skill helps you create or enhance project instruction files (instructions.md, CLAUDE.md, .claude/instructions.md, etc.) with parallel invocation patterns that enable efficient concurrent execution of agents and skills.

**Use this skill when**:
- Starting a new project and want to document parallel execution patterns
- Enhancing existing project instructions with parallel invocation guidance
- Standardizing parallel patterns across multiple projects
- Team needs consistent documentation on when/how to parallelize agent invocations

**Complementary to**:
- **toolkit-manager**: Creates agents/skills; this skill documents how to use them efficiently
- **workflow-orchestrator**: Plans complex workflows; this skill documents general patterns
- **Global instructions.md**: System-level instructions; this creates project-specific guidance

## Prerequisites

Before using this skill:
- Understand the difference between parallel and sequential execution
- Know the Task tool invocation pattern (multiple calls in single message = parallel)
- Identify which agents/skills exist in the project
- Determine project-specific parallelization needs

## Workflow

### Step 1: Determine Instruction File Location

**Identify or create the project instruction file**:

**Common locations**:
- `.claude/instructions.md` (project root, checked into git)
- `instructions.md` (project root)
- `CLAUDE.md` (alternative name)
- `docs/claude-instructions.md` (documentation folder)

**Best practice**: Use `.claude/instructions.md` for git-tracked, team-shared instructions.

### Step 2: Analyze Project Patterns

**Identify common parallel invocation scenarios in your project**:

**Questions to ask**:
1. What batch operations happen frequently? (e.g., "analyze all tests", "review all API endpoints")
2. Which agents/skills are used together but independently?
3. Are there multi-step workflows with parallel opportunities?
4. What are common anti-patterns to document (sequential when could be parallel)?

**Document your findings**:
- List common batch operations
- Identify agents used frequently
- Note sequential vs parallel opportunities
- Document project-specific constraints

### Step 3: Choose Instruction Sections to Add

**Core sections for parallel invocation patterns**:

1. **Batch Operations Pattern** - How to handle "all/multiple/every" requests
2. **Parallel Task Invocation Best Practices** - When and how to parallelize
3. **Agent Selection Guidelines** - Which agents for which tasks
4. **Complex Workflow Guidelines** - Multi-phase execution patterns
5. **Project-Specific Examples** - Concrete scenarios from your codebase

**Minimal viable instructions**: Include sections 1, 2, and 5 at minimum.

### Step 4: Write Batch Operations Pattern Section

**Template**:

```markdown
## Batch Operations Pattern

When handling requests involving multiple items (keywords: "all", "multiple", "every"):

### Standard Approach for Simple Batch Operations

1. **Identify Items**: Use Glob/Grep to discover all items
2. **Select Agent**: Determine which specialized agent handles each item
3. **Parallel Invocation**: Launch multiple Task tool calls in a SINGLE message
4. **Aggregate Results**: Collect and summarize findings

### Example Pattern

**User request**: "[insert project-specific example]"

**Correct approach**:
1. Use Glob to find items: `[project path pattern]`
2. Identify [agent-name] as the appropriate agent
3. Launch multiple Task invocations in ONE message (all parallel)
4. Aggregate results and report patterns
```

**Customization**:
- Replace example with actual project scenario
- Use real file paths from your project
- Reference actual agents available in the project

### Step 5: Write Parallel Task Invocation Best Practices

**Template**:

```markdown
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
- [Add project-specific criteria]

### When NOT to Parallelize
- Tasks have dependencies (one needs output from another)
- Sequential execution required by nature of work
- Risk of conflicts (e.g., editing same file)
- [Add project-specific constraints]

### Project-Specific Parallelization Rules
[Document any project-specific considerations, e.g.:]
- Database migrations must run sequentially
- API endpoint implementations can be parallel
- Test suites can be analyzed in parallel
- Deployment steps must be sequential
```

**Customization**:
- Add project-specific parallelization criteria
- Document known conflicts or constraints
- Include domain-specific rules (database, API, infrastructure)

### Step 6: Add Project-Specific Examples

**Provide 3-5 concrete examples from your project**:

**Example template**:

```markdown
## Project-Specific Examples

### Example 1: [Scenario Name]

**User request**: "[actual request user might make]"

**Parallelization opportunity**: [explain why this can be parallel]

**Execution pattern**:
1. [Step 1]
2. [Step 2 - invoke multiple agents in parallel]
3. [Step 3]

**Agents used**: [@agent-name-1, @agent-name-2, @agent-name-3]

**Expected outcome**: [what should result]

### Example 2: [Another Scenario]
[Repeat pattern]
```

**Common project scenarios to document**:
- Analyzing multiple modules/services
- Reviewing API endpoints
- Running test suites
- Validating configuration files
- Generating documentation for multiple components
- Security auditing multiple areas

### Step 7: Document Anti-Patterns

**Add section on common mistakes**:

```markdown
## Common Anti-Patterns to Avoid

### Anti-Pattern 1: Sequential Batch Operations
**Wrong**:
- Process item 1, wait for result
- Process item 2, wait for result
- Process item 3, wait for result

**Right**:
- Process items 1, 2, 3 simultaneously in single message
- Collect all results together

### Anti-Pattern 2: Over-Orchestration
**Wrong**:
- Delegate simple batch operations to workflow-orchestrator
- Add unnecessary complexity for independent tasks

**Right**:
- Use workflow-orchestrator only for complex multi-phase workflows
- Handle simple batch operations with parallel Task invocations

### Anti-Pattern 3: [Project-Specific Anti-Pattern]
[Document common mistakes specific to your project]
```

### Step 8: Add Decision Framework

**Help users decide when to parallelize**:

```markdown
## Decision Framework: Parallel vs Sequential

### Use PARALLEL execution when:
- ✅ Tasks are independent (no shared state)
- ✅ Order doesn't matter (commutative operations)
- ✅ No file conflicts (different files or read-only)
- ✅ Same operation on multiple items
- [Add project criteria]

### Use SEQUENTIAL execution when:
- ❌ Tasks have dependencies (A needs B's output)
- ❌ Order matters (migration steps, deployment phases)
- ❌ Risk of conflicts (editing same file)
- ❌ Resource constraints (database locks, API rate limits)
- [Add project criteria]

### Use WORKFLOW ORCHESTRATOR when:
- Requires 3+ different specialized agents
- Has sequential dependencies between phases
- Mixes parallel and sequential execution
- Complex multi-phase development workflow
```

### Step 9: Validate and Test

**Checklist for quality instructions**:
- [ ] Examples use actual project paths and agents
- [ ] Parallel patterns are clearly explained
- [ ] Decision framework is actionable
- [ ] Anti-patterns are documented with alternatives
- [ ] Project-specific constraints are noted
- [ ] File is formatted correctly (Markdown)
- [ ] Instructions work when followed by team

**Testing approach**:
1. Follow your own instructions for a real scenario
2. Ask team member to use instructions on actual task
3. Identify gaps or confusion
4. Iterate and refine

### Step 10: Maintain and Update

**Keep instructions current**:

**Update when**:
- New agents/skills added to project
- New parallel patterns discovered
- Team identifies confusion or gaps
- Project constraints change (new infrastructure, tools)

**Maintenance schedule**:
- Review quarterly or after major changes
- Document version history in git commits
- Solicit team feedback regularly

## Key Principles

### Principle 1: Make It Actionable
Instructions should be concrete enough to follow without guessing. Use real examples, actual file paths, and specific agent names.

### Principle 2: Document the "Why"
Explain WHY parallelization matters, not just HOW. Help users understand the benefits and constraints.

### Principle 3: Project-Specific Over Generic
Generic advice is less useful. Tailor every section to your project's actual patterns, agents, and workflows.

### Principle 4: Show Don't Tell
Provide concrete examples over abstract rules. One good example is worth paragraphs of explanation.

### Principle 5: Evolve With Usage
Instructions are living documents. Update based on real team usage and feedback.

## Supporting Patterns

### Pattern 1: Independent Analysis Tasks
**Use case**: Analyzing multiple independent items (files, modules, endpoints)

**Template**:
```
Identify items → Select single agent → Invoke agent N times in parallel → Aggregate
```

**Example**: "Analyze all API endpoints for security issues" → List endpoints → @security-auditor for each → Parallel Task calls → Summary report

### Pattern 2: Multi-Concern Review
**Use case**: Different agents reviewing different aspects of same item

**Template**:
```
Identify item → Select multiple agents → Invoke all agents in parallel → Aggregate results
```

**Example**: "Review feature implementation" → @code-reviewer (quality) + @security-auditor (security) + @performance-engineer (performance) → Parallel invocations → Combined report

### Pattern 3: Batch Creation/Generation
**Use case**: Creating multiple similar items

**Template**:
```
Define specifications → Select creation agent → Invoke agent N times in parallel → Verify all outputs
```

**Example**: "Generate tests for all service methods" → List methods → @test-automator for each → Parallel invocations → Verify coverage

### Pattern 4: Hierarchical Processing
**Use case**: Processing tree structures (directories, component hierarchies)

**Template**:
```
Map hierarchy → Group by level → Process each level in parallel → Aggregate by level
```

**Example**: "Analyze component tree" → Map components → @architect-reviewer for each level in parallel → Hierarchical report

## Examples

### Example 1: Creating Instructions for Django API Project

**Project context**: Django REST API with 20+ endpoints, event-sourced architecture

**User request**: "Create project instructions with parallel patterns"

**Actions taken**:
1. Created `.claude/instructions.md`
2. Added batch operations pattern with example: "analyze all API endpoints"
3. Documented parallel patterns for:
   - Endpoint security review (@security-auditor)
   - Event sourcing validation (@architect-reviewer + project skill)
   - Test coverage analysis (@test-automator)
4. Added anti-pattern: sequential endpoint reviews (should be parallel)
5. Documented constraint: database migrations must be sequential
6. Added 4 project-specific examples with actual endpoint paths
7. Referenced project agents: django-developer, security-auditor, test-automator

**Expected outcome**: Team can efficiently parallelize API reviews and development tasks

### Example 2: Enhancing Existing Instructions for Microservices Project

**Project context**: 15 microservices, Kubernetes deployment, shared instructions

**User request**: "Add parallel invocation patterns to our existing CLAUDE.md"

**Actions taken**:
1. Read existing `CLAUDE.md` (had basic agent list)
2. Added new section: "Parallel Batch Operations"
3. Documented pattern: "analyze all services for deployment readiness"
   - @kubernetes-specialist for manifests (parallel)
   - @security-auditor for vulnerabilities (parallel)
   - @test-automator for integration tests (parallel)
4. Added decision framework specific to microservices:
   - Parallel: service-level operations (no dependencies)
   - Sequential: cross-service migrations, deployment rollouts
5. Added 3 examples using actual service names
6. Documented anti-pattern: sequential service deployments (should be parallel in dev)

**Expected outcome**: Faster multi-service operations, clear guidance on when to parallelize

### Example 3: Standardizing Across Multiple Projects

**Project context**: Team has 10 projects, wants consistent parallel patterns

**User request**: "Create template instructions I can adapt for each project"

**Actions taken**:
1. Created `parallel-instructions-template.md` in team wiki
2. Structured with clear "[CUSTOMIZE]" markers:
   - "[PROJECT_NAME]"
   - "[AGENT_LIST]"
   - "[COMMON_OPERATIONS]"
3. Provided 3 filled examples:
   - Django project version
   - React frontend version
   - Microservices version
4. Created checklist for customization:
   - Replace all [PLACEHOLDERS]
   - Add 3+ project-specific examples
   - Document project constraints
   - List available agents
5. Added to team onboarding: "Copy template → Customize → Commit to project"

**Expected outcome**: Consistent parallel patterns across all team projects with project-specific customization

### Example 4: Instructions for Multi-Repo Monorepo

**Project context**: Monorepo with 8 packages, shared tooling, complex dependencies

**User request**: "Document parallel patterns that respect package dependencies"

**Actions taken**:
1. Created `.claude/instructions.md` in monorepo root
2. Mapped package dependency graph
3. Documented parallel patterns:
   - **Within package**: parallel (no conflicts)
   - **Across independent packages**: parallel
   - **Across dependent packages**: sequential (respecting dep order)
4. Added decision tree:
   ```
   Same package? → Parallel (if independent files)
   Different packages? → Check dependency graph
     Independent? → Parallel
     Dependent? → Sequential (dependency order)
   ```
5. Added 5 examples with actual package names and dependency arrows
6. Documented anti-pattern: parallelizing across dependent packages

**Expected outcome**: Safe parallelization respecting package boundaries and dependencies

## Quick Reference

### Parallel Invocation Checklist

Use this checklist when adding parallel patterns to project instructions:

- [ ] Batch operations pattern documented with project example
- [ ] "When to parallelize" criteria listed
- [ ] "When NOT to parallelize" constraints documented
- [ ] Decision framework provided (parallel vs sequential)
- [ ] 3+ project-specific examples included
- [ ] Common anti-patterns documented with alternatives
- [ ] Agent selection guidance provided
- [ ] Project constraints explicitly noted
- [ ] Examples use actual project paths/agents
- [ ] Instructions validated by team member

### Template Snippets

**Minimal batch operations section**:
```markdown
## Batch Operations Pattern

When processing multiple items:
1. Identify items with Glob/Grep
2. Select appropriate agent
3. Invoke agent multiple times in SINGLE message (parallel)
4. Aggregate results

Example: [project-specific scenario]
```

**Minimal decision framework**:
```markdown
## Parallel vs Sequential

Parallel: Independent tasks, no shared state, no conflicts
Sequential: Dependencies, order matters, file conflicts
```

**Minimal example**:
```markdown
## Example: [Scenario]
Request: "[user request]"
Pattern: [agent] invoked N times in parallel
Agents: [@agent-name]
Outcome: [expected result]
```

## Integration with Other Tools

### Complementary Skills
- **meta-skill**: For creating new skills that leverage parallel patterns
- **event-sourcing-patterns**: Project-specific skill showing parallel aggregate analysis

### Complementary Agents
- **toolkit-manager**: Creates agents/skills; this skill documents how to use them efficiently
- **workflow-orchestrator**: Plans complex workflows; this skill teaches when to use it vs parallel Task invocations
- **code-reviewer**: May be invoked in parallel for batch code reviews
- **architect-reviewer**: May be invoked in parallel for multi-module architecture reviews

### Complementary Documentation
- Official Claude Code docs on Task tool
- Official Sub-agents documentation
- Project README (general project context)
- Agent/skill documentation in project

---

**Remember**: Good project instructions make parallel invocation patterns concrete and actionable. Always use real project examples, actual agent names, and specific file paths. Generic advice is less useful than one good project-specific example.
