---
name: Project Instructions Generator
description: Guides users in creating comprehensive project instructions (instructions.md, CLAUDE.md, etc.) that include agent discovery, parallel invocation patterns, dynamic agent selection, and orchestrated workflow recommendations. Use this when user wants to create project instructions for a new project, enhance existing instructions with best practices, document available agents and skills, add parallel execution patterns, or standardize project documentation across multiple projects.
allowed-tools: [Read, Write, Edit, Grep, Glob]
---

# Instructions

## Purpose

This skill helps you create comprehensive project instruction files (instructions.md, CLAUDE.md, .claude/instructions.md, etc.) that enable efficient Claude Code usage through:
- **Agent discovery and documentation** - Identifying and documenting available global and local agents
- **Parallel invocation patterns** - Enabling efficient concurrent execution
- **Dynamic agent selection** - Guiding intelligent agent choice based on tasks
- **Orchestrated workflows** - Recommending workflow patterns for complex jobs

**Use this skill when**:
- Starting a new project and want comprehensive Claude Code instructions
- Enhancing existing project instructions with agent discovery and parallel patterns
- Documenting available agents and when to use global vs local agents
- Standardizing project documentation across multiple projects
- Team needs consistent documentation on agent selection and parallelization

**Complementary to**:
- **toolkit-manager**: Creates agents/skills; this skill documents how to use them efficiently
- **workflow-orchestrator**: Plans complex workflows; this skill documents general patterns
- **Global instructions.md**: System-level instructions; this creates project-specific guidance

## Prerequisites

Before using this skill:
- Understand the difference between global agents (~/.claude/agents/) and local agents (.claude/agents/)
- Know the difference between parallel and sequential execution
- Know the Task tool invocation pattern (multiple calls in single message = parallel)
- Understand when to use workflow-orchestrator vs simple parallel invocations
- Be familiar with the project structure and common workflows

## Workflow

### Step 1: Determine Instruction File Location

**Identify or create the project instruction file**:

**Common locations**:
- `.claude/instructions.md` (project root, checked into git)
- `instructions.md` (project root)
- `CLAUDE.md` (alternative name)
- `docs/claude-instructions.md` (documentation folder)

**Best practice**: Use `.claude/instructions.md` for git-tracked, team-shared instructions.

### Step 2: Discover and Document Available Agents

**Identify all available agents that Claude can use for the project**:

**Step 2.1: Discover Global Agents**

Use Glob to find all global agents:
```
Glob pattern: ~/.claude/agents/*.md
```

For each global agent found:
1. Read the agent file to understand its purpose and capabilities
2. Note the agent name (from frontmatter)
3. Note the description (what it does and when to use it)
4. Identify key tools and specializations
5. Determine if relevant to this project

**Step 2.2: Discover Local Agents**

Check for project-specific agents:
```
Glob pattern: .claude/agents/*.md
```

For each local agent found:
1. Read the agent file to understand its purpose
2. Note why it's project-specific (project patterns, domain knowledge)
3. Document its relationship to global agents (complements, overrides, specializes)

**Step 2.3: Document Agent Inventory**

Create a section in project instructions listing available agents:

```markdown
## Available Agents

### Global Agents (Reusable across projects)

- **@agent-name-1**: [Brief description of what it does and when to use]
- **@agent-name-2**: [Brief description]
- **@agent-name-3**: [Brief description]

### Local Agents (Project-specific)

- **@project-agent-1**: [Why project-specific, what it handles]
- **@project-agent-2**: [Project-specific concerns]

### Agent Selection Guidelines

**Use global agents when**:
- Task fits general-purpose capability (code review, testing, security)
- No project-specific patterns required
- Standard best practices apply

**Use local agents when**:
- Task requires project-specific domain knowledge
- Project has unique patterns or conventions
- Local agent provides specialized validation or implementation

**Dynamic selection**: Claude should automatically select the most appropriate agent based on:
- Task requirements and context
- Available agent capabilities
- Project-specific vs general needs
- Opportunity for parallel invocation
```

**Step 2.4: Document When to Create Local Agents**

Add guidance for when the team should create project-specific agents:

```markdown
### When to Create Project-Specific Agents

Create a local agent when:
- Project has unique domain patterns not covered by global agents
- Specialized validation requires project knowledge
- Implementation patterns are project-specific (e.g., event sourcing, CQRS)
- Team needs custom orchestration for project workflows

Keep using global agents when:
- Standard practices apply (code review, testing, security)
- No project-specific customization needed
- Global agent is sufficient
```

### Step 3: Analyze Project Patterns

**Identify common execution patterns in your project**:

**Questions to ask**:
1. What batch operations happen frequently? (e.g., "analyze all tests", "review all API endpoints")
2. Which agents/skills are used together but independently?
3. Are there multi-step workflows with parallel opportunities?
4. Are there complex jobs requiring orchestration across multiple specialized agents?
5. What are common anti-patterns to document (sequential when could be parallel)?

**Document your findings**:
- List common batch operations (candidates for parallelization)
- Identify agents used frequently together
- Note sequential vs parallel opportunities
- Identify complex multi-phase workflows (candidates for orchestration)
- Document project-specific constraints

### Step 4: Choose Instruction Sections to Add

**Core sections for comprehensive project instructions**:

1. **Available Agents** - Agent inventory and selection guidelines (from Step 2)
2. **Parallelization Best Practices** - When and how to leverage parallel execution
3. **Dynamic Agent Selection** - How Claude should intelligently choose agents
4. **Orchestrated Workflows** - When and how to use workflow-orchestrator
5. **Batch Operations Pattern** - How to handle "all/multiple/every" requests
6. **Project-Specific Examples** - Concrete scenarios from your codebase

**Minimal viable instructions**: Include sections 1, 2, 4, 5, and 6 at minimum.

### Step 5: Add Parallelization and Dynamic Agent Selection

**Template for parallelization guidance**:

```markdown
## Parallelization Best Practices

### Core Principle
**ALWAYS leverage parallel execution when possible**. Claude can invoke multiple agents simultaneously in a single message, dramatically improving efficiency.

### When to Parallelize
✅ **Independent tasks** - No dependencies between tasks
✅ **Batch operations** - Processing multiple items with same agent
✅ **Multi-concern analysis** - Different agents analyzing different aspects
✅ **Different files** - No risk of edit conflicts
✅ **Read-only operations** - Analysis, review, validation

### How to Parallelize
Make multiple Task tool calls in a **single response message**:
- All agents execute simultaneously (not sequential)
- Results aggregate together
- Dramatically faster than sequential execution

### Dynamic Agent Selection

**Claude should intelligently choose agents based on**:
1. **Task requirements** - Match task to agent capabilities
2. **Global vs local** - Prefer local agents for project-specific patterns
3. **Specialization** - Use most specialized agent for the job
4. **Parallel opportunities** - Identify when multiple agents can work together
5. **Available context** - Consider what information agents need

### Agent Selection Decision Tree

```
Task requires project-specific knowledge?
  YES → Use local agent if available
  NO → Use global agent

Multiple independent items?
  YES → Invoke same agent N times in parallel
  NO → Single agent invocation

Multiple aspects to analyze?
  YES → Invoke multiple different agents in parallel
  NO → Single agent invocation

Complex multi-phase workflow?
  YES → Consider workflow-orchestrator
  NO → Direct agent invocation(s)
```

### Project-Specific Parallelization Rules
[Document project-specific guidelines, e.g.:]
- Database migrations: sequential only
- API endpoint reviews: always parallel
- Test file analysis: parallel by default
- Integration tests: consider dependencies
```

**Customization**:
- Add project-specific parallelization rules
- Document known constraints or conflicts
- Provide examples of good parallel patterns

### Step 6: Add Orchestrated Workflow Guidance

**Template for orchestration guidance**:

```markdown
## Orchestrated Workflows

### When to Use workflow-orchestrator

**DEFAULT to workflow-orchestrator for complex jobs involving**:
✅ **Multiple specialized agents** (3+ different agents)
✅ **Sequential dependencies** (Phase B needs Phase A results)
✅ **Mixed parallel + sequential** (Some phases parallel, some sequential)
✅ **Complex coordination** (Agents need to coordinate outputs)
✅ **Multi-phase development** (Design → Implement → Test → Deploy)

### When NOT to Use workflow-orchestrator

**Use simple parallel invocations for**:
❌ **Simple batch operations** (same agent, multiple items)
❌ **Independent tasks** (no coordination needed)
❌ **Single-phase work** (one type of operation)
❌ **Quick reviews** (simple parallel analysis)

### Orchestration Patterns

**Pattern 1: Sequential phases with internal parallelization**
- Phase 1: Design (single agent)
- Phase 2: Implementation (parallel - multiple components)
- Phase 3: Testing (parallel - multiple test types)
- Phase 4: Review (parallel - multiple reviewers)

**Pattern 2: Complex feature development**
- @architect-reviewer: Design validation
- @[domain]-developer: Implementation (parallel for multiple modules)
- @test-automator: Test generation (parallel)
- @code-reviewer: Final review
- @documentation-engineer: Documentation

**Pattern 3: Project-specific workflows**
[Document common orchestrated workflows for your project]

### Example Orchestrated Workflow Request

"Implement new [feature] with full workflow":
1. Use workflow-orchestrator
2. Phases: Design → Implement → Test → Review → Document
3. Leverage parallel execution within each phase
4. Ensure proper handoffs between phases
```

**Customization**:
- Document project-specific orchestrated workflows
- Add examples of when to use orchestrator vs parallel invocations
- Note any project constraints on workflow patterns

### Step 7: Write Batch Operations Pattern Section

**Template**:

```markdown
## Batch Operations Pattern

When handling requests involving multiple items (keywords: "all", "multiple", "every"):

### Standard Approach for Simple Batch Operations

1. **Identify Items**: Use Glob/Grep to discover all items
2. **Select Agent**: Determine which specialized agent handles each item (global vs local)
3. **Parallel Invocation**: Launch multiple Task tool calls in a SINGLE message
4. **Aggregate Results**: Collect and summarize findings

### Example Pattern

**User request**: "[insert project-specific example]"

**Correct approach**:
1. Use Glob to find items: `[project path pattern]`
2. Dynamically select appropriate agent (e.g., @[agent-name] for project-specific patterns)
3. Launch multiple Task invocations in ONE message (all parallel)
4. Aggregate results and report patterns
```

**Customization**:
- Replace example with actual project scenario
- Use real file paths from your project
- Reference actual agents available (both global and local)
- Note when to prefer local vs global agents

### Step 8: Write Parallel Task Invocation Best Practices (Optional)

**Note**: This section is optional if you already covered parallelization in Step 5. Use this for additional detail or project-specific nuances.

**Template**:

```markdown
## Additional Parallelization Guidelines

### Benefits of Parallel Execution
- All agents run simultaneously (not sequential)
- Faster completion time (N tasks in parallel vs sequential)
- Efficient resource usage
- Better user experience

### Project-Specific Parallelization Rules
[Document any project-specific considerations, e.g.:]
- Database migrations: must run sequentially
- API endpoint implementations: can be parallel
- Test suites: can be analyzed in parallel
- Deployment steps: must be sequential
- [Your project-specific rules]
```

**Customization**:
- Add project-specific parallelization criteria
- Document known conflicts or constraints
- Include domain-specific rules (database, API, infrastructure)

### Step 9: Add Project-Specific Examples

**Provide 3-5 concrete examples from your project**:

**Example template**:

```markdown
## Project-Specific Examples

### Example 1: [Scenario Name]

**User request**: "[actual request user might make]"

**Agent selection**: [Which agents to use - global vs local, why]

**Execution pattern**:
1. [Step 1 - agent discovery/selection]
2. [Step 2 - parallel or orchestrated execution]
3. [Step 3 - aggregation]

**Agents used**: [@agent-name-1 (global/local), @agent-name-2 (global/local)]

**Parallelization**: [Parallel invocation | Orchestrated workflow]

**Expected outcome**: [what should result]

### Example 2: Complex Orchestrated Workflow

**User request**: "[complex multi-phase request]"

**Agent selection**: Multiple specialized agents required

**Execution pattern**:
1. Use @workflow-orchestrator
2. Phase 1: [@agent-a] for design
3. Phase 2: [@agent-b, @agent-c] in parallel for implementation
4. Phase 3: [@agent-d] for review

**Why orchestrated**: Multiple phases, dependencies, coordination needed

**Expected outcome**: [full workflow completion]

### Example 3: [Another Scenario]
[Repeat pattern]
```

**Common project scenarios to document**:
- Analyzing multiple modules/services (parallel)
- Reviewing API endpoints (parallel with dynamic agent selection)
- Complex feature development (orchestrated)
- Running test suites (parallel)
- Validating configuration files (parallel with local agent)
- Generating documentation for multiple components (parallel)
- Security auditing multiple areas (parallel)
- Multi-phase deployment workflow (orchestrated)

### Step 10: Document Anti-Patterns

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
- Leverage parallel execution for independent tasks

### Anti-Pattern 2: Over-Orchestration
**Wrong**:
- Delegate simple batch operations to workflow-orchestrator
- Add unnecessary complexity for independent tasks

**Right**:
- Use workflow-orchestrator for complex multi-phase workflows
- Handle simple batch operations with parallel Task invocations

### Anti-Pattern 3: Not Using Available Local Agents
**Wrong**:
- Use generic global agent for project-specific patterns
- Miss project-specific validation or implementation logic

**Right**:
- Discover and use local agents for project-specific tasks
- Leverage project knowledge embedded in local agents

### Anti-Pattern 4: Missing Parallelization Opportunities
**Wrong**:
- Invoke agents sequentially when they could run in parallel
- Process independent items one at a time

**Right**:
- Default to parallel execution for independent tasks
- Only use sequential when dependencies exist

### Anti-Pattern 5: [Project-Specific Anti-Pattern]
[Document common mistakes specific to your project]
```

### Step 11: Add Decision Framework

**Help users decide execution strategy**:

```markdown
## Decision Framework

### Agent Selection Decision
```
Is task project-specific?
  YES → Check for local agent
    Found? → Use local agent
    Not found? → Consider creating local agent OR use global agent
  NO → Use appropriate global agent

Multiple similar items?
  YES → Same agent invoked N times in parallel
  NO → Single agent invocation

Multiple different aspects?
  YES → Different agents invoked in parallel
  NO → Single agent invocation
```

### Execution Strategy Decision
```
Simple batch operation (same agent, multiple items)?
  → PARALLEL invocation (multiple Task calls in one message)

Multiple independent tasks (different agents)?
  → PARALLEL invocation (multiple Task calls in one message)

Complex multi-phase workflow (3+ agents, dependencies)?
  → ORCHESTRATED workflow (use @workflow-orchestrator)

Sequential dependencies exist?
  → SEQUENTIAL execution OR orchestrated workflow

File edit conflicts possible?
  → SEQUENTIAL execution
```

### Use PARALLEL execution when:
- ✅ Tasks are independent (no shared state)
- ✅ Order doesn't matter (commutative operations)
- ✅ No file conflicts (different files or read-only)
- ✅ Same operation on multiple items
- ✅ Different agents analyzing different aspects
- [Add project criteria]

### Use SEQUENTIAL execution when:
- ❌ Tasks have dependencies (A needs B's output)
- ❌ Order matters (migration steps, deployment phases)
- ❌ Risk of conflicts (editing same file)
- ❌ Resource constraints (database locks, API rate limits)
- [Add project criteria]

### Use WORKFLOW ORCHESTRATOR when:
- ✅ Requires 3+ different specialized agents
- ✅ Has sequential dependencies between phases
- ✅ Mixes parallel and sequential execution
- ✅ Complex multi-phase development workflow
- ✅ Need coordination between agent outputs
```

### Step 12: Validate and Test

**Checklist for quality instructions**:
- [ ] Agent inventory includes both global and local agents
- [ ] Agent selection guidelines are clear (global vs local)
- [ ] Dynamic agent selection guidance provided
- [ ] Parallelization patterns are clearly explained
- [ ] Orchestrated workflow guidance included
- [ ] Decision framework is actionable
- [ ] Examples use actual project paths and agents
- [ ] Anti-patterns are documented with alternatives
- [ ] Project-specific constraints are noted
- [ ] File is formatted correctly (Markdown)
- [ ] Instructions work when followed by team

**Testing approach**:
1. Follow your own instructions for a real scenario
2. Test both parallel and orchestrated workflow examples
3. Verify agent discovery process works
4. Ask team member to use instructions on actual task
5. Identify gaps or confusion
6. Iterate and refine

### Step 13: Maintain and Update

**Keep instructions current**:

**Update when**:
- New agents added (global or local)
- New skills added to project
- New parallel patterns discovered
- New orchestrated workflows identified
- Team identifies confusion or gaps
- Agent responsibilities change
- Project constraints change (new infrastructure, tools)

**Maintenance schedule**:
- Review agent inventory when new agents created
- Review quarterly or after major changes
- Document version history in git commits
- Solicit team feedback regularly
- Update examples as project evolves

## Key Principles

### Principle 1: Document Available Agents
Always include agent inventory (global and local). Claude needs to know what agents exist to make intelligent selection decisions.

### Principle 2: Default to Parallel
Encourage parallel execution by default. Only use sequential when necessary (dependencies, conflicts, order matters).

### Principle 3: Leverage Orchestration for Complexity
Complex multi-phase workflows benefit from orchestration. Document when to use workflow-orchestrator vs simple parallel invocations.

### Principle 4: Make It Actionable
Instructions should be concrete enough to follow without guessing. Use real examples, actual file paths, and specific agent names (both global and local).

### Principle 5: Document the "Why"
Explain WHY to choose certain agents, parallelize, or orchestrate - not just HOW. Help users understand the benefits and constraints.

### Principle 6: Project-Specific Over Generic
Generic advice is less useful. Tailor every section to your project's actual patterns, agents, and workflows.

### Principle 7: Show Don't Tell
Provide concrete examples over abstract rules. One good example is worth paragraphs of explanation.

### Principle 8: Evolve With Usage
Instructions are living documents. Update agent inventory, patterns, and examples based on real team usage and feedback.

## Supporting Patterns

### Pattern 1: Independent Analysis Tasks (Parallel)
**Use case**: Analyzing multiple independent items (files, modules, endpoints)

**Agent selection**: Choose most appropriate agent (global or local) based on task

**Template**:
```
Identify items → Select single agent (dynamic selection) → Invoke agent N times in parallel → Aggregate
```

**Example**: "Analyze all API endpoints for security issues" → List endpoints → @security-auditor (global) for each → Parallel Task calls → Summary report

### Pattern 2: Multi-Concern Review (Parallel)
**Use case**: Different agents reviewing different aspects of same item

**Agent selection**: Multiple specialized agents (mix of global and local)

**Template**:
```
Identify item → Select multiple agents → Invoke all agents in parallel → Aggregate results
```

**Example**: "Review feature implementation" → @code-reviewer (global, quality) + @security-auditor (global, security) + @event-sourcing-validator (local, project patterns) → Parallel invocations → Combined report

### Pattern 3: Batch Creation/Generation (Parallel)
**Use case**: Creating multiple similar items

**Agent selection**: Appropriate creation agent (prefer local if project-specific)

**Template**:
```
Define specifications → Select creation agent → Invoke agent N times in parallel → Verify all outputs
```

**Example**: "Generate tests for all service methods" → List methods → @test-automator (global) for each → Parallel invocations → Verify coverage

### Pattern 4: Hierarchical Processing (Parallel)
**Use case**: Processing tree structures (directories, component hierarchies)

**Agent selection**: Architecture or domain-specific agent

**Template**:
```
Map hierarchy → Group by level → Process each level in parallel → Aggregate by level
```

**Example**: "Analyze component tree" → Map components → @architect-reviewer (global) for each level in parallel → Hierarchical report

### Pattern 5: Complex Multi-Phase Workflow (Orchestrated)
**Use case**: Complex job requiring multiple specialized agents with dependencies

**Agent selection**: Use @workflow-orchestrator to coordinate multiple agents

**Template**:
```
Define workflow → Use @workflow-orchestrator → Phase 1 (design) → Phase 2 (implement, parallel) → Phase 3 (test, parallel) → Phase 4 (review)
```

**Example**: "Implement new user authentication feature" → @workflow-orchestrator coordinates → @architect-reviewer (design) → @backend-developer + @frontend-developer (parallel implementation) → @test-automator + @security-auditor (parallel validation) → @code-reviewer (final review)

### Pattern 6: Dynamic Agent Selection with Local Override
**Use case**: Task that may have project-specific implementation

**Agent selection**: Check local agents first, fall back to global

**Template**:
```
Check for local agent → If exists, use local → Otherwise, use appropriate global agent
```

**Example**: "Validate event sourcing aggregate" → Check for @event-sourcing-validator (local) → If exists, use it → Otherwise, use @architect-reviewer (global)

## Examples

### Example 1: Creating Comprehensive Instructions for Django API Project

**Project context**: Django REST API with 20+ endpoints, event-sourced architecture

**User request**: "Create comprehensive project instructions"

**Actions taken**:
1. Created `.claude/instructions.md`
2. **Discovered and documented agents**:
   - Global agents: @code-reviewer, @security-auditor, @test-automator, @documentation-engineer
   - Local agents: @event-sourcing-validator (project-specific validation)
   - Added agent selection guidelines (when to use local vs global)
3. **Added parallelization best practices**:
   - Core principle: default to parallel
   - Dynamic agent selection based on task
   - Decision tree for execution strategy
4. **Documented orchestrated workflows**:
   - When to use @workflow-orchestrator
   - Example: Feature development workflow
5. **Added batch operations pattern** with example: "analyze all API endpoints"
6. **Documented parallel patterns for**:
   - Endpoint security review (@security-auditor, parallel)
   - Event sourcing validation (@event-sourcing-validator local agent, parallel)
   - Test coverage analysis (@test-automator, parallel)
7. **Added anti-patterns**:
   - Sequential endpoint reviews (should be parallel)
   - Not using local @event-sourcing-validator when available
8. **Documented constraints**: database migrations must be sequential
9. **Added 5 project-specific examples** with actual endpoint paths, agent selection rationale
10. **Included orchestration example**: "Implement new feature with full workflow"

**Expected outcome**: Team can efficiently discover agents, parallelize work, leverage orchestration, and make intelligent agent selection decisions

### Example 2: Enhancing Existing Instructions for Microservices Project

**Project context**: 15 microservices, Kubernetes deployment, shared instructions

**User request**: "Enhance our existing CLAUDE.md with comprehensive agent discovery and execution patterns"

**Actions taken**:
1. Read existing `CLAUDE.md` (had basic setup info)
2. **Added agent discovery section**:
   - Discovered 12 global agents (kubernetes-specialist, security-auditor, test-automator, etc.)
   - Discovered 2 local agents (@service-mesh-validator, @deployment-orchestrator)
   - Documented when to use each
3. **Added parallelization best practices**:
   - Default to parallel for service-level operations
   - Dynamic agent selection based on task type
4. **Added orchestrated workflow guidance**:
   - Use @workflow-orchestrator for cross-service features
   - Example: "Add authentication to all services" workflow
5. **Documented pattern**: "analyze all services for deployment readiness"
   - @kubernetes-specialist for manifests (parallel)
   - @security-auditor for vulnerabilities (parallel)
   - @service-mesh-validator (local) for mesh config (parallel)
   - @test-automator for integration tests (parallel)
6. **Added decision framework** specific to microservices:
   - Parallel: independent service-level operations
   - Sequential: cross-service migrations, deployment rollouts
   - Orchestrated: multi-service feature development
7. **Added 5 examples** using actual service names
8. **Documented anti-patterns**:
   - Sequential service deployments in dev (should be parallel)
   - Not using @service-mesh-validator for mesh config
   - Over-orchestrating simple multi-service analysis

**Expected outcome**: Team can discover available agents, parallelize multi-service operations, orchestrate complex cross-service features, and make intelligent agent choices

### Example 3: Standardizing Across Multiple Projects

**Project context**: Team has 10 projects, wants consistent comprehensive instructions

**User request**: "Create template instructions I can adapt for each project"

**Actions taken**:
1. Created `project-instructions-template.md` in team wiki
2. **Structured with clear "[CUSTOMIZE]" markers**:
   - "[PROJECT_NAME]"
   - "[GLOBAL_AGENTS_RELEVANT_TO_PROJECT]"
   - "[LOCAL_AGENTS]"
   - "[COMMON_OPERATIONS]"
   - "[ORCHESTRATED_WORKFLOWS]"
3. **Included all major sections**:
   - Agent discovery and inventory template
   - Agent selection guidelines
   - Parallelization best practices
   - Orchestrated workflow patterns
   - Decision framework
   - Project-specific examples (with placeholders)
4. **Provided 3 filled examples**:
   - Django project version (with local @event-sourcing-validator)
   - React frontend version (with local @component-validator)
   - Microservices version (with local @service-mesh-validator, @deployment-orchestrator)
5. **Created customization checklist**:
   - Discover and list global agents relevant to project
   - Discover and list local agents
   - Replace all [PLACEHOLDERS]
   - Add 3+ project-specific examples
   - Document orchestrated workflows
   - Document project constraints
6. Added to team onboarding: "Copy template → Discover agents → Customize → Commit to project"

**Expected outcome**: Consistent comprehensive instructions across all team projects with agent discovery, parallelization, orchestration, and project-specific customization

### Example 4: Instructions for Multi-Repo Monorepo

**Project context**: Monorepo with 8 packages, shared tooling, complex dependencies

**User request**: "Create comprehensive instructions that respect package dependencies"

**Actions taken**:
1. Created `.claude/instructions.md` in monorepo root
2. **Discovered and documented agents**:
   - Global agents: @code-reviewer, @test-automator, @dependency-analyzer
   - Local agents: @package-validator (validates cross-package contracts)
3. **Mapped package dependency graph** and documented it
4. **Documented parallelization patterns**:
   - **Within package**: parallel (if independent files)
   - **Across independent packages**: parallel
   - **Across dependent packages**: sequential OR orchestrated (respecting dep order)
5. **Added orchestration guidance**:
   - Use @workflow-orchestrator for changes affecting multiple dependent packages
   - Example: "Update shared interface across packages" → orchestrated workflow
6. **Added decision tree**:
   ```
   Same package? → Parallel (if independent files)
   Different packages? → Check dependency graph
     Independent? → Parallel
     Dependent? → Check complexity
       Simple? → Sequential (dependency order)
       Complex? → Orchestrated workflow
   ```
7. **Added 6 examples** with actual package names, dependency arrows, and agent selection
8. **Documented anti-patterns**:
   - Parallelizing across dependent packages
   - Not using @package-validator for contract validation
   - Manual sequencing instead of orchestrator for complex cross-package changes

**Expected outcome**: Safe parallelization respecting package boundaries, intelligent orchestration for complex cross-package work, and proper agent selection

## Quick Reference

### Comprehensive Project Instructions Checklist

Use this checklist when creating project instructions:

**Agent Discovery & Documentation**:
- [ ] Global agents discovered and listed
- [ ] Local agents discovered and listed
- [ ] Agent selection guidelines provided (global vs local)
- [ ] Dynamic agent selection guidance included
- [ ] When to create local agents documented

**Parallelization**:
- [ ] Parallelization best practices documented
- [ ] "When to parallelize" criteria listed
- [ ] "When NOT to parallelize" constraints documented
- [ ] Batch operations pattern documented with project example
- [ ] Examples show parallel invocation patterns

**Orchestration**:
- [ ] When to use workflow-orchestrator documented
- [ ] When NOT to use orchestrator documented
- [ ] Orchestrated workflow patterns provided
- [ ] Complex multi-phase workflow examples included

**Decision Framework**:
- [ ] Agent selection decision tree provided
- [ ] Execution strategy decision framework included
- [ ] Parallel vs sequential vs orchestrated criteria clear

**Examples & Anti-Patterns**:
- [ ] 3+ project-specific examples included
- [ ] Examples show agent selection rationale
- [ ] Common anti-patterns documented with alternatives
- [ ] Project constraints explicitly noted
- [ ] Examples use actual project paths/agents

**Validation**:
- [ ] File is formatted correctly (Markdown)
- [ ] Instructions validated by team member

### Template Snippets

**Minimal agent inventory section**:
```markdown
## Available Agents

### Global Agents
- @code-reviewer: Code quality and best practices
- @security-auditor: Security vulnerability scanning
- [Add others relevant to project]

### Local Agents
- @[project-agent]: [Project-specific capability]

### Agent Selection Guidelines
- Use local agents for project-specific patterns
- Use global agents for standard practices
- Claude should dynamically select based on task
```

**Minimal parallelization section**:
```markdown
## Parallelization

**Default to parallel execution** for independent tasks.

- ✅ Parallel: Independent tasks, different files, read-only
- ❌ Sequential: Dependencies, file conflicts, order matters
- 🔄 Orchestrated: Complex multi-phase workflows (3+ agents)

Invoke multiple agents in SINGLE message for parallel execution.
```

**Minimal orchestration section**:
```markdown
## Orchestrated Workflows

Use @workflow-orchestrator for:
- Complex multi-phase workflows
- 3+ different specialized agents
- Sequential dependencies between phases

Example: "Implement new feature" → @workflow-orchestrator coordinates design, implementation, testing, review
```

**Minimal batch operations section**:
```markdown
## Batch Operations Pattern

When processing multiple items:
1. Identify items with Glob/Grep
2. Dynamically select appropriate agent (local if project-specific)
3. Invoke agent multiple times in SINGLE message (parallel)
4. Aggregate results

Example: [project-specific scenario]
```

**Minimal example**:
```markdown
## Example: [Scenario]
Request: "[user request]"
Agent selection: [@agent-name] (global/local) - [why]
Pattern: [Parallel invocation | Orchestrated workflow]
Outcome: [expected result]
```

## Integration with Other Tools

### Complementary Skills
- **meta-skill**: For creating new skills that can be documented in project instructions
- **event-sourcing-patterns**: Example of project-specific skill that can be referenced in instructions

### Complementary Agents
- **toolkit-manager**: Creates agents/skills; this skill documents how to discover and use them efficiently
- **workflow-orchestrator**: Orchestrates complex workflows; this skill teaches when to use it vs parallel invocations
- **All global agents**: Can be discovered and documented in project instructions
- **All local agents**: Should be inventoried and explained in project instructions

### Complementary Documentation
- Official Claude Code docs on Task tool and parallel invocation
- Official Sub-agents documentation
- Agent and skill documentation (both global and local)
- Project README (general project context)

---

## Summary

**This skill helps you create comprehensive project instructions that:**

1. **Document available agents** - Inventory global and local agents, explain when to use each
2. **Enable parallelization** - Default to parallel execution for efficiency
3. **Guide dynamic agent selection** - Help Claude choose the right agent for each task
4. **Leverage orchestration** - Use workflow-orchestrator for complex multi-phase jobs
5. **Provide concrete examples** - Show real project scenarios with agent selection rationale

**Remember**: Good project instructions make agent discovery, parallelization, and orchestration patterns concrete and actionable. Always:
- List available agents (global and local)
- Use real project examples with actual agent names
- Show agent selection rationale
- Include both parallel and orchestrated workflow examples
- Document project-specific constraints
- Default to parallel execution whenever possible

Generic advice is less useful than one good project-specific example showing agent discovery, selection, and execution pattern.
