---
name: Create Custom Agent Configuration
description: |
  ⚠️ DEPRECATED: Use @meta-orchestrator instead.
  This skill has been superseded by the unified meta-orchestrator agent.
  Previously generated complete Claude Code agent configuration files from user descriptions.
---

# ⚠️ DEPRECATED

**This skill has been superseded by the `meta-orchestrator` agent.**

**Use instead**: `@meta-orchestrator` for:
- Creating new agents
- Creating new skills
- Analyzing agents/skills for redundancy
- Deciding whether to create an agent or skill
- Managing the agent/skill ecosystem

**Why deprecated?**
- Redundant with `meta-agent` (both created agents)
- Lacked analysis and maintenance capabilities
- No decision framework for agent vs skill
- Superseded by unified meta-orchestrator

**Migration path**: Simply use `@meta-orchestrator` for all meta operations.

Supporting files from this skill have been migrated to `~/.claude/agents/meta-orchestrator/`

---

# Original Instructions (Archived)

## Prerequisites
- Understanding of what the agent should accomplish
- Knowledge of when the agent should be activated
- Identification of required tools and domain expertise

## Workflow

### Step 1: Fetch Latest Documentation
Retrieve the current agent configuration format and best practices:

```bash
WebFetch https://code.claude.com/docs/en/sub-agents.md
```

This ensures the generated agent uses the latest configuration format and follows current best practices.

### Step 2: Analyze User Requirements
From the user's description, identify:

**Core Purpose:**
- What is the agent's primary responsibility?
- What domain expertise does it capture?
- What problem does it solve?

**Delegation Triggers:**
- When should this agent be invoked?
- What keywords or scenarios trigger its use?
- Should it be proactive or on-demand?

**Required Capabilities:**
- What tools does it need? (Read, Write, Edit, Grep, Glob, Bash, etc.)
- Does it need web access? (WebFetch, WebSearch)
- Does it need MCP tools? (IDE integration, external services)

### Step 3: Generate Agent Configuration

**3.1 Create Agent Name:**
- Use kebab-case format
- Reflect primary function
- Keep concise (2-3 words max)
- Examples: `code-reviewer`, `test-generator`, `api-designer`

**3.2 Select Color:**
Choose from: `red`, `orange`, `yellow`, `green`, `blue`, `purple`, `pink`, `cyan`, `gray`

**Color Guidelines:**
- **Red/Orange:** Urgent, critical (security, bugs)
- **Yellow:** Attention, warnings (performance, optimization)
- **Green:** Success, building (implementation, features)
- **Blue:** Information, analysis (documentation, research)
- **Purple:** Architecture, design (planning, review)
- **Pink:** Testing, QA (validation, quality)
- **Cyan:** Infrastructure, ops (deployment, DevOps)
- **Gray:** Utility, general (helpers, tools)

**3.3 Write Description:**
Create a clear, action-oriented description:
- State what the agent does
- Include when to use it
- Add trigger phrases
- Use "Use proactively for..." or "Delegate when..."

Example:
```
description: |
  Expert code reviewer validating S.O.L.I.D principles and best practices.
  Use proactively after code changes. Delegate when reviewing PRs or ensuring code quality.
```

**3.4 Determine Tools:**
Select the minimal required set:

**Common Tool Combinations:**
- **Read-only analysis:** `[Read, Grep, Glob]`
- **Code generation:** `[Read, Write, Edit, Grep, Glob]`
- **Testing:** `[Read, Write, Bash, Grep]`
- **Documentation:** `[Read, Write, WebFetch, Grep, Glob]`
- **Full implementation:** `[Read, Write, Edit, Bash, Grep, Glob]`
- **Research:** `[Read, Grep, Glob, WebFetch, WebSearch]`

**Tool Restrictions:**
Use `disallowedTools` for safety:
- Analysis agents: `disallowedTools: [Write, Edit, Bash]`
- Read-only reviewers: `disallowedTools: [Write, Edit, Bash]`

**3.5 Select Model:**
- **haiku:** Simple, fast tasks (formatting, file organization) - cheapest
- **sonnet:** Balanced reasoning (code review, documentation) - recommended
- **opus:** Complex reasoning (architecture, debugging) - most expensive

**3.6 Write System Prompt:**
Define the agent's role and expertise:
```markdown
# Purpose

[Agent role in 2-3 sentences defining expertise and responsibility]

## Instructions

When invoked, follow these steps:

1. [First concrete action]
2. [Second concrete action]
3. [Third concrete action]

## Best Practices

- [Domain-specific practice 1]
- [Domain-specific practice 2]
- [Domain-specific practice 3]

## Output Format

[How the agent should structure its response]
```

### Step 4: Write Agent File

Save to `~/.claude/agents/[agent-name].md`:

```markdown
---
name: [agent-name]
description: [Clear description with delegation triggers]
tools: [Required tools only]
color: [chosen-color]
model: [haiku|sonnet|opus]
disallowedTools: [optional safety restrictions]
---

# Purpose

[Agent role definition]

## Instructions

When invoked, follow these steps:

1. [Action step]
2. [Action step]
3. [Action step]

## Best Practices

- [Practice 1]
- [Practice 2]

## Output Format

[Response structure]
```

### Step 5: Validate Configuration

Check the generated file:
- [ ] YAML frontmatter is valid
- [ ] Name is kebab-case
- [ ] Description includes delegation triggers
- [ ] Tools list is minimal but sufficient
- [ ] Model choice matches complexity
- [ ] Instructions are actionable (numbered steps)
- [ ] Best practices are domain-specific

### Step 6: Report Creation

Provide summary to user:
```
✅ Created new agent: [agent-name]

📁 Location: ~/.claude/agents/[agent-name].md
🎯 Purpose: [What it does]
🔧 Tools: [Tool list]
💡 Usage: @[agent-name] or let Claude delegate automatically
```

## Agent Configuration Patterns

### Pattern 1: Analysis Agent (Read-Only)
**Purpose:** Code review, security audit, architecture analysis

```yaml
tools: [Read, Grep, Glob]
color: blue
model: sonnet
disallowedTools: [Write, Edit, Bash]
```

**Example:** Security auditor, code complexity analyzer, dependency reviewer

### Pattern 2: Implementation Agent (Full Access)
**Purpose:** Feature implementation, refactoring, code generation

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
color: green
model: sonnet
```

**Example:** Feature developer, refactoring specialist, migration tool

### Pattern 3: Testing Agent
**Purpose:** Test generation, test execution, coverage validation

```yaml
tools: [Read, Write, Bash, Grep, Glob]
color: pink
model: sonnet
```

**Example:** Test generator, test runner, coverage analyzer

### Pattern 4: Documentation Agent
**Purpose:** Documentation generation, API schemas, technical writing

```yaml
tools: [Read, Write, WebFetch, Grep, Glob]
color: blue
model: sonnet
```

**Example:** API docs generator, OpenAPI schema creator, README writer

### Pattern 5: Infrastructure Agent
**Purpose:** Deployment, configuration, DevOps tasks

```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
color: cyan
model: sonnet
```

**Example:** Kubernetes specialist, CI/CD manager, deployment orchestrator

### Pattern 6: Research Agent
**Purpose:** Information gathering, best practices lookup, trend analysis

```yaml
tools: [Read, Grep, Glob, WebFetch, WebSearch]
color: purple
model: sonnet
disallowedTools: [Write, Edit, Bash]
```

**Example:** Research analyst, documentation fetcher, trend analyzer

## Best Practices for Agent Creation

### DO:
✅ **Focus on one primary responsibility**
✅ **Use minimal required tools** (add more only if needed)
✅ **Write actionable, numbered instructions**
✅ **Include delegation triggers in description**
✅ **Choose appropriate model for complexity**
✅ **Restrict tools for safety** (read-only agents)
✅ **Test the agent after creation**

### DON'T:
❌ **Create agents that do everything** (keep focused)
❌ **Grant unnecessary tool access** (security risk)
❌ **Write vague instructions** (be specific and actionable)
❌ **Use Opus for simple tasks** (cost inefficient)
❌ **Forget delegation triggers** (unclear when to use)
❌ **Skip validation** (might have errors)

# Examples

## Example 1: Creating a Security Review Agent

**User Request:** "Create an agent that reviews code for security vulnerabilities"

**Actions Taken:**
1. Fetched sub-agents.md documentation
2. Analyzed requirements:
   - Purpose: Security vulnerability detection
   - Triggers: Code changes, PR reviews, security audits
   - Tools: Read-only (no modifications during audit)
3. Generated configuration:
   ```yaml
   name: security-auditor
   description: |
     Reviews code for OWASP Top 10 vulnerabilities and security best practices.
     Use proactively after code changes or when security audit is requested.
   tools: [Read, Grep, Glob]
   color: red
   model: sonnet
   disallowedTools: [Write, Edit, Bash]
   ```
4. Created instructions:
   - Scan for SQL injection patterns
   - Check XSS protection
   - Validate authentication/authorization
   - Review secret management
5. Wrote to `~/.claude/agents/security-auditor.md`

**Expected Outcome:**
```
✅ Created new agent: security-auditor

📁 Location: ~/.claude/agents/security-auditor.md
🎯 Purpose: Reviews code for security vulnerabilities
🔧 Tools: Read, Grep, Glob (read-only for audit integrity)
💡 Usage: @security-auditor or auto-delegates on code changes
```

## Example 2: Creating a Test Generation Agent

**User Request:** "Make an agent that generates comprehensive pytest tests"

**Actions Taken:**
1. Fetched latest documentation
2. Analyzed requirements:
   - Purpose: Pytest test generation
   - Triggers: New features, missing coverage
   - Tools: Read (analyze code), Write (generate tests), Bash (run tests)
3. Generated configuration:
   ```yaml
   name: pytest-generator
   description: |
     Generates comprehensive pytest tests with fixtures and parametrization.
     Delegate when new features need tests or coverage is insufficient.
   tools: [Read, Write, Bash, Grep, Glob]
   color: pink
   model: sonnet
   ```
4. Created instructions:
   - Analyze code structure and logic
   - Identify test scenarios (positive, negative, edge cases)
   - Generate tests with fixtures
   - Run tests to verify they pass
   - Check coverage metrics
5. Wrote to `~/.claude/agents/pytest-generator.md`

**Expected Outcome:**
```
✅ Created new agent: pytest-generator

📁 Location: ~/.claude/agents/pytest-generator.md
🎯 Purpose: Generates comprehensive pytest tests
🔧 Tools: Read, Write, Bash, Grep, Glob
💡 Usage: @pytest-generator when tests are needed
```

## Example 3: Creating an API Documentation Agent

**User Request:** "Create agent for maintaining OpenAPI schemas"

**Actions Taken:**
1. Fetched sub-agents.md
2. Analyzed requirements:
   - Purpose: OpenAPI schema generation and maintenance
   - Triggers: API endpoint changes, schema updates
   - Tools: Read (scan code), Write (update schema), WebFetch (validation)
3. Generated configuration:
   ```yaml
   name: openapi-maintainer
   description: |
     Generates and maintains OpenAPI 3.1 schemas from Django REST Framework endpoints.
     Use proactively when API endpoints change or schema validation is needed.
   tools: [Read, Write, WebFetch, Grep, Glob, Bash]
   color: blue
   model: sonnet
   ```
4. Created instructions:
   - Scan ViewSets and serializers
   - Generate OpenAPI schema components
   - Validate against OpenAPI 3.1 spec
   - Update schema files
   - Verify no breaking changes
5. Wrote to `~/.claude/agents/openapi-maintainer.md`

**Expected Outcome:**
```
✅ Created new agent: openapi-maintainer

📁 Location: ~/.claude/agents/openapi-maintainer.md
🎯 Purpose: Maintains OpenAPI schemas for Django REST Framework
🔧 Tools: Read, Write, WebFetch, Grep, Glob, Bash
💡 Usage: Auto-delegates when API endpoints change
```

## Example 4: Creating a Performance Optimization Agent

**User Request:** "Build an agent that optimizes database queries"

**Actions Taken:**
1. Fetched documentation
2. Analyzed requirements:
   - Purpose: Database query optimization
   - Triggers: Slow queries, performance issues
   - Tools: Read (analyze queries), Bash (run EXPLAIN), Write (fixes)
3. Generated configuration:
   ```yaml
   name: query-optimizer
   description: |
     Optimizes database queries for performance using EXPLAIN analysis and indexing strategies.
     Delegate when queries are slow (>100ms) or N+1 patterns detected.
   tools: [Read, Write, Edit, Bash, Grep, Glob]
   color: yellow
   model: sonnet
   ```
4. Created instructions:
   - Identify slow queries using logging
   - Run EXPLAIN ANALYZE
   - Detect N+1 query patterns
   - Recommend indexes
   - Implement select_related/prefetch_related
   - Verify performance improvement
5. Wrote to `~/.claude/agents/query-optimizer.md`

**Expected Outcome:**
```
✅ Created new agent: query-optimizer

📁 Location: ~/.claude/agents/query-optimizer.md
🎯 Purpose: Optimizes database queries for <100ms execution
🔧 Tools: Read, Write, Edit, Bash, Grep, Glob
💡 Usage: @query-optimizer for slow query investigation
```

# Supporting Documentation

For detailed agent configuration options and advanced patterns, see:
- [agent-templates.md](agent-templates.md) - Ready-to-use agent templates
- [tool-selection-guide.md](tool-selection-guide.md) - Choosing the right tools
- [delegation-patterns.md](delegation-patterns.md) - When agents should activate

---

**Quick Reference:**

| Agent Type | Tools | Model | Color | DisallowedTools |
|------------|-------|-------|-------|-----------------|
| Analysis | Read, Grep, Glob | sonnet | blue | Write, Edit, Bash |
| Implementation | Read, Write, Edit, Bash, Grep, Glob | sonnet | green | - |
| Testing | Read, Write, Bash, Grep, Glob | sonnet | pink | - |
| Documentation | Read, Write, WebFetch, Grep, Glob | sonnet | blue | Bash |
| Infrastructure | Read, Write, Edit, Bash, Grep, Glob | sonnet | cyan | - |
| Research | Read, Grep, Glob, WebFetch, WebSearch | sonnet | purple | Write, Edit, Bash |
