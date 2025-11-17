# Agent vs Skill Decision Framework

This guide helps you determine whether a requirement calls for an agent (autonomous executor) or a skill (reference guide).

## Core Distinction

**Agent**: Autonomous system that EXECUTES tasks
**Skill**: Reference guide that INSTRUCTS how to execute tasks

Think of it this way:
- **Agent** = "I'll do it for you"
- **Skill** = "Here's how to do it"

## Decision Tree

Start here and follow the branches:

```
┌─────────────────────────────────────┐
│ What do you need to accomplish?     │
└──────────────┬──────────────────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Should this EXECUTE  │
    │ actions autonomously?│
    └───┬─────────────┬────┘
        │             │
       YES           NO
        │             │
        ▼             ▼
    ┌────────┐   ┌──────────┐
    │ AGENT  │   │  SKILL   │
    └────────┘   └──────────┘
```

### Follow-up Questions

If still uncertain, ask these:

**1. File Modifications?**
- ✅ YES → **AGENT** (Write, Edit capabilities)
- ❌ NO → Continue to #2

**2. Command Execution?**
- ✅ YES → **AGENT** (Bash, test running, deployment)
- ❌ NO → Continue to #3

**3. Multi-step Workflow?**
- ✅ YES, complex orchestration → **AGENT**
- ✅ YES, but reference guide → **SKILL**

**4. Decision Making?**
- ✅ YES, autonomous decisions → **AGENT**
- ❌ NO, provides criteria → **SKILL**

**5. Validation Only?**
- ✅ YES, checklist review → **SKILL**
- ❌ NO, implements fixes → **AGENT**

## Detailed Criteria

### Create an AGENT when:

#### 1. Autonomous Execution Required
**Indicator**: System should take actions without asking permission

**Examples**:
- ✅ "Review code and fix style violations"
- ✅ "Generate API documentation from code"
- ✅ "Optimize database queries"
- ✅ "Deploy to staging environment"

**Not**:
- ❌ "Checklist for reviewing code style"
- ❌ "Guidelines for API documentation"

#### 2. File Modifications Needed
**Indicator**: Must create, edit, or delete files

**Examples**:
- ✅ Code generation
- ✅ Refactoring
- ✅ Configuration updates
- ✅ Documentation generation

**Not**:
- ❌ Reading and analyzing files
- ❌ Recommending changes without implementing

#### 3. Command Execution Required
**Indicator**: Must run terminal commands

**Examples**:
- ✅ Running tests
- ✅ Building projects
- ✅ Deploying applications
- ✅ Database migrations
- ✅ Performance profiling

**Not**:
- ❌ Checklist for manual test execution
- ❌ Guidelines for deployment process

#### 4. Complex Multi-Step Workflows
**Indicator**: Orchestrates multiple tools and operations

**Examples**:
- ✅ "Implement feature end-to-end: models → views → tests → docs"
- ✅ "Refactor module: analyze → plan → execute → verify"
- ✅ "Security audit: scan → report → remediate → verify"

**Not**:
- ❌ "Checklist for implementing a feature"
- ❌ "Steps to follow when refactoring"

#### 5. Proactive Behavior Needed
**Indicator**: Should automatically trigger based on context

**Examples**:
- ✅ Code reviewer triggers on file changes
- ✅ Documentation engineer triggers on API changes
- ✅ Security auditor triggers on security-sensitive code

**Not**:
- ❌ Manual reference when reviewing code
- ❌ Checklist consulted when needed

#### 6. Broad Domain Expertise
**Indicator**: Comprehensive knowledge and capabilities in a domain

**Examples**:
- ✅ Django developer (full Django stack)
- ✅ Kubernetes specialist (all k8s operations)
- ✅ Database optimizer (query optimization, indexing, profiling)

**Not**:
- ❌ Django migration checklist (narrow concern)
- ❌ Kubernetes manifest validation (specific check)

### Create a SKILL when:

#### 1. Reference Guide / Checklist
**Indicator**: Provides validation criteria or patterns to follow

**Examples**:
- ✅ "Django migration review checklist"
- ✅ "Event sourcing patterns validation"
- ✅ "Security audit checklist"
- ✅ "Code review guidelines"

**Not**:
- ❌ "Automated Django migration reviewer"
- ❌ "Event sourcing implementation generator"

#### 2. Validation-Focused
**Indicator**: Used to review existing work against standards

**Examples**:
- ✅ Check migration files for safety
- ✅ Validate event sourcing patterns
- ✅ Review Kubernetes manifests
- ✅ Verify API documentation completeness

**Not**:
- ❌ Generate migrations
- ❌ Implement event sourcing
- ❌ Create Kubernetes manifests

#### 3. Project-Specific Patterns
**Indicator**: Captures team conventions or project standards

**Examples**:
- ✅ "widget-service event naming conventions"
- ✅ "Our team's Django model patterns"
- ✅ "Project-specific k8s configuration rules"

**Not**:
- ❌ General framework best practices (use agent)

#### 4. Quick Reference / Reminder
**Indicator**: Lightweight checklist for manual review

**Examples**:
- ✅ "Before committing migrations"
- ✅ "When implementing a projection"
- ✅ "Kubernetes deployment checklist"

**Not**:
- ❌ Automated pre-commit migration checker

#### 5. Read-Only Context
**Indicator**: Provides information without taking action

**Examples**:
- ✅ Patterns to look for
- ✅ Common issues to flag
- ✅ Best practices to follow
- ✅ Examples of good/bad code

**Not**:
- ❌ Automatically fix the issues

#### 6. Narrow, Focused Scope
**Indicator**: Covers one specific concern

**Examples**:
- ✅ Django migration safety (not all Django)
- ✅ Event naming conventions (not all event sourcing)
- ✅ Resource limits in k8s (not all k8s)

**Not**:
- ❌ Comprehensive domain coverage (use agent)

## Comparison Table

| Aspect | Agent | Skill |
|--------|-------|-------|
| **Action** | Executes | Instructs |
| **Files** | Creates/Modifies | Reads/References |
| **Commands** | Runs | Describes |
| **Decisions** | Makes autonomously | Provides criteria |
| **Scope** | Broad domain | Narrow concern |
| **Trigger** | Automatic (proactive) | Manual (on-demand) |
| **Tools** | Write, Edit, Bash, etc. | Read, Grep (usually) |
| **Output** | Modified code/system | Analysis report |
| **Examples** | code-reviewer, django-developer | django-migration-review, event-sourcing-patterns |

## Common Scenarios

### Scenario 1: Code Review

**Requirement**: "Ensure code follows best practices"

**Questions**:
- Should it automatically fix issues?
  - YES → **Agent** (`code-reviewer` with edit capabilities)
  - NO → **Skill** (code review checklist)

**Best Practice**: **Agent** - code review benefits from autonomous execution and contextual understanding

### Scenario 2: Django Migrations

**Requirement**: "Validate Django migrations are safe"

**Questions**:
- Should it modify migration files?
  - YES → **Agent** (migration fixer)
  - NO, just review → **Skill** (migration review checklist)

**Best Practice**: **Skill** - migrations are sensitive, manual review with checklist is safer

### Scenario 3: API Documentation

**Requirement**: "Keep API documentation up to date"

**Questions**:
- Should it automatically update OpenAPI schema?
  - YES → **Agent** (`documentation-engineer`)
  - NO, just provide checklist → **Skill**

**Best Practice**: **Agent** - documentation generation benefits from automation and can be proactive on API changes

### Scenario 4: Event Sourcing Patterns

**Requirement**: "Ensure event sourcing follows DDD patterns"

**Questions**:
- Should it implement aggregates?
  - YES → **Agent** (event sourcing implementer)
  - NO, validate existing → **Skill** (event sourcing patterns validation)

**Best Practice**: **Both**!
- **Skill** (`create-event-sourced-aggregate`): Step-by-step creation guide
- **Skill** (`event-sourcing-patterns`): Validation checklist

### Scenario 5: Kubernetes Deployments

**Requirement**: "Manage Kubernetes deployments"

**Questions**:
- Should it create/modify manifests?
  - YES → **Agent** (`kubernetes-specialist`)
  - NO, just validate → **Skill** (k8s manifest validation)

**Best Practice**: **Both**!
- **Agent** (`kubernetes-specialist`): Creates and modifies manifests
- **Skill** (`kubernetes-manifest-validation`): Project-specific validation checklist

### Scenario 6: Security Audits

**Requirement**: "Check for security vulnerabilities"

**Questions**:
- Should it scan code automatically?
  - YES → **Agent** (`security-auditor`)
  - NO, just provide checklist → **Skill**

**Best Practice**: **Agent** - security scanning benefits from automation and can be proactive

### Scenario 7: Test Generation

**Requirement**: "Generate comprehensive tests"

**Questions**:
- Should it write test files?
  - YES → **Agent** (`test-automator`)
  - NO, just provide patterns → **Skill** (testing patterns)

**Best Practice**: **Agent** - test generation requires file creation and execution

## When to Use BOTH

Sometimes you need both an agent AND a skill:

**Pattern: Agent Implements, Skill Validates**

**Example 1: Kubernetes**
- **Agent** (`kubernetes-specialist`): Creates/modifies manifests
- **Skill** (`kubernetes-manifest-validation`): Project-specific validation checklist

**Why Both?**
- Agent provides general k8s expertise
- Skill captures project-specific rules and conventions
- Skill provides quick validation reference

**Example 2: Event Sourcing**
- **Skill** (`create-event-sourced-aggregate`): Creation workflow guide
- **Skill** (`event-sourcing-patterns`): Validation checklist

**Why Both?**
- Creation guide walks through implementation
- Validation checklist reviews finished work
- Different phases of the workflow

**Example 3: Code Quality**
- **Agent** (`code-reviewer`): Automated code review
- **Skill** (project-specific): Team coding standards

**Why Both?**
- Agent provides general code quality review
- Skill captures team-specific conventions
- Skill provides context agent may lack

## Red Flags (Avoid These)

### ❌ Creating Both When One Suffices

**Problem**: `django-expert` (agent) + `django-guide` (skill) with 80% overlap

**Solution**: Choose one based on primary need:
- Need execution? → Keep agent only
- Need reference? → Keep skill only

### ❌ Skill That Should Be an Agent

**Indicators**:
- Skill describes commands to run
- Skill would be better automated
- Users keep asking "can you just do this?"

**Example**: "Deployment checklist" with 10 bash commands
**Solution**: Create deployment agent instead

### ❌ Agent That Should Be a Skill

**Indicators**:
- Agent only analyzes, never modifies
- Agent just provides recommendations
- Users want quick reference, not full execution

**Example**: Agent that only reads and reports
**Solution**: Convert to skill with checklist

### ❌ Overlapping Responsibilities

**Problem**: Multiple agents/skills covering same ground

**Example**:
- `api-designer` (agent)
- `api-documenter` (agent)
- `api-documentation-update` (skill)

**Solution**: Consolidate into `api-specialist` agent or clarify boundaries

## Decision Shortcuts

### Quick Yes/No Test

**Create an AGENT if ANY of these are true:**
- [ ] Must create or modify files
- [ ] Must run terminal commands
- [ ] Should work autonomously
- [ ] Needs to make complex decisions
- [ ] Should trigger proactively

**Create a SKILL if ALL of these are true:**
- [ ] Reference guide / checklist
- [ ] Validation-focused
- [ ] Read-only / non-destructive
- [ ] Manual invocation
- [ ] Narrow, focused scope

### Examples Mapped

| Need | Type | Name | Why |
|------|------|------|-----|
| Review PR for quality | **Agent** | code-reviewer | Autonomous analysis, proactive |
| Migration safety checklist | **Skill** | django-migration-review | Validation checklist, manual |
| Generate API docs | **Agent** | documentation-engineer | File creation, proactive |
| Event sourcing patterns | **Skill** | event-sourcing-patterns | Validation reference |
| Deploy to k8s | **Agent** | kubernetes-specialist | Commands, file mods |
| K8s manifest checklist | **Skill** | kubernetes-manifest-validation | Project-specific validation |
| Optimize database queries | **Agent** | database-optimizer | Analysis + fixes, commands |
| Code security scan | **Agent** | security-auditor | Automated scanning |

## Final Checklist

Before creating, verify your choice:

**Agent Checklist:**
- [ ] Purpose requires autonomous execution
- [ ] Will create, modify, or delete files OR run commands
- [ ] Benefits from proactive triggering
- [ ] Provides broad domain expertise
- [ ] User wants "do it for me" not "show me how"

**Skill Checklist:**
- [ ] Purpose is validation or reference
- [ ] Read-only analysis or guidance
- [ ] Manual invocation preferred
- [ ] Narrow, focused concern
- [ ] User wants "checklist" or "patterns to follow"

## Still Unsure?

**Default to Agent if:**
- Automation would save significant time
- Task is repetitive and well-defined
- Execution is safer than manual steps

**Default to Skill if:**
- Task requires human judgment
- Project-specific conventions involved
- Quick reference is primary need
- Safety requires manual review

---

**Remember**: When in doubt, ask the user:
- "Should this run automatically or provide a checklist?"
- "Do you want me to execute this or guide you through it?"
- "Is this a reference guide or an autonomous executor?"
