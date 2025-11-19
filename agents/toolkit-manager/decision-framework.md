# Agent vs Skill vs Hook Decision Framework

This guide helps you determine whether a requirement calls for an agent (autonomous executor), a skill (reference guide), or a hook (event handler).

## Core Distinction

**Agent**: Autonomous system that EXECUTES tasks
**Skill**: Reference guide that INSTRUCTS how to execute tasks
**Hook**: Event-driven handler that RESPONDS to Claude Code events

Think of it this way:
- **Agent** = "I'll do it for you"
- **Skill** = "Here's how to do it"
- **Hook** = "I'll remind you when it matters"

## Decision Tree

Start here and follow the branches:

```
┌─────────────────────────────────────────┐
│ What do you need to accomplish?         │
└──────────────┬──────────────────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │ Should this RESPOND to        │
    │ Claude Code events?           │
    └───┬─────────────────────┬────┘
        │                     │
       YES                   NO
        │                     │
        ▼                     ▼
    ┌──────┐      ┌──────────────────────┐
    │ HOOK │      │ Should this EXECUTE  │
    └──────┘      │ actions autonomously?│
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

**1. Event-Driven Behavior?**
- ✅ YES, responds to SessionStart/UserPromptSubmit/etc. → **HOOK**
- ❌ NO → Continue to #2

**2. File Modifications?**
- ✅ YES → **AGENT** (Write, Edit capabilities)
- ❌ NO → Continue to #3

**3. Command Execution?**
- ✅ YES, runs commands to accomplish task → **AGENT** (Bash, test running, deployment)
- ✅ YES, but just injects context → **HOOK** (runs script for discovery)
- ❌ NO → Continue to #4

**4. Multi-step Workflow?**
- ✅ YES, complex orchestration → **AGENT**
- ✅ YES, but reference guide → **SKILL**

**5. Decision Making?**
- ✅ YES, autonomous decisions → **AGENT**
- ❌ NO, provides criteria → **SKILL**

**6. Validation Only?**
- ✅ YES, checklist review → **SKILL**
- ❌ NO, implements fixes → **AGENT**

**7. Context Injection?**
- ✅ YES, adds reminders at specific moments → **HOOK**
- ❌ NO → Continue evaluating

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

### Create a HOOK when:

#### 1. Event-Driven Behavior Required
**Indicator**: Should respond to specific Claude Code lifecycle events

**Examples**:
- ✅ "Remind about parallelization on every user prompt"
- ✅ "Inject session context at startup"
- ✅ "Discover project agents when entering directory"
- ✅ "Show checklist before commits"

**Not**:
- ❌ "Analyze code quality" (use agent)
- ❌ "Provide code review checklist" (use skill)

#### 2. Context Injection Needed
**Indicator**: Adds information or reminders at specific moments

**Examples**:
- ✅ Available agent roster
- ✅ Project-specific conventions reminder
- ✅ Workflow enhancement suggestions
- ✅ Environment validation warnings

**Not**:
- ❌ Detailed implementation guide (use skill)
- ❌ Autonomous execution (use agent)

#### 3. Dynamic Discovery Required
**Indicator**: Must gather project-specific information at runtime

**Examples**:
- ✅ Discover available agents/skills
- ✅ Detect project configuration
- ✅ Find relevant environment variables
- ✅ Check prerequisites

**Not**:
- ❌ Static information (hardcode or use skill)
- ❌ Complex analysis (use agent)

#### 4. Workflow Enhancement Without Replacement
**Indicator**: Augments existing workflows rather than replacing them

**Examples**:
- ✅ Remind about best practices
- ✅ Inject helpful context
- ✅ Validate prerequisites
- ✅ Guide through complex workflows

**Not**:
- ❌ Replace existing functionality (use agent)
- ❌ Comprehensive implementation (use agent)

#### 5. Consistent Behavior Across Sessions
**Indicator**: Same action should happen for all matching events

**Examples**:
- ✅ Always check for parallelization opportunities
- ✅ Always load project context at startup
- ✅ Always validate environment on directory change
- ✅ Always remind about project conventions

**Not**:
- ❌ Conditional complex logic (use agent)
- ❌ One-time setup (manual configuration)

#### 6. Lightweight, Fast Operations
**Indicator**: Quick operations that don't slow down Claude Code

**Examples**:
- ✅ Read configuration file
- ✅ List directory contents
- ✅ Check file existence
- ✅ Output predefined text

**Not**:
- ❌ Complex computations (use agent)
- ❌ Long-running processes (use agent)

## Comparison Table

| Aspect | Agent | Skill | Hook |
|--------|-------|-------|------|
| **Action** | Executes | Instructs | Responds to events |
| **Files** | Creates/Modifies | Reads/References | Reads only |
| **Commands** | Runs for execution | Describes | Runs for discovery |
| **Decisions** | Makes autonomously | Provides criteria | Minimal logic |
| **Scope** | Broad domain | Narrow concern | Event-specific |
| **Trigger** | Automatic (proactive) | Manual (on-demand) | Automatic (event-driven) |
| **Tools** | Write, Edit, Bash, etc. | Read, Grep (usually) | Shell scripts |
| **Output** | Modified code/system | Analysis report | System reminders |
| **Configuration** | .md file in agents/ | .md file in skills/ | JSON in settings.json |
| **Examples** | code-reviewer, django-developer | django-migration-review | parallelization-reminder, agent-discovery |

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

### Scenario 8: Parallelization Reminders

**Requirement**: "Remind me to use parallel agents when appropriate"

**Questions**:
- Should this execute agents in parallel automatically?
  - YES → **Agent** (workflow orchestrator)
  - NO, just remind → **Hook** (UserPromptSubmit)

**Best Practice**: **Hook** - lightweight reminder that doesn't interfere with workflow, fires before each user prompt

### Scenario 9: Project Context Discovery

**Requirement**: "Load project-specific agents when starting session"

**Questions**:
- Should this happen automatically on SessionStart?
  - YES → **Hook** (discover and inject context)
  - NO, manual lookup → **Skill** (agent directory guide)

**Best Practice**: **Hook** - dynamic discovery at session start ensures current context

### Scenario 10: Pre-Commit Validation

**Requirement**: "Check for issues before committing"

**Questions**:
- Should this run automatically before git operations?
  - YES, and fix issues → **Agent** (pre-commit fixer)
  - YES, but just remind → **Hook** (validation checklist reminder)
  - NO, manual checklist → **Skill** (commit checklist)

**Best Practice**: **Hook** or **Agent** depending on whether you want automatic fixes or just reminders

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

**Example 4: Parallelization Workflow**
- **Hook** (`parallelization-reminder`): Reminds to consider parallel agents
- **Agent** (`workflow-orchestrator`): Executes multi-agent workflows

**Why Both?**
- Hook provides timely reminder on every prompt
- Agent handles actual orchestration when needed
- Complementary: reminder → decision → execution

**Example 5: Session Context**
- **Hook** (`agent-discovery`): Discovers and lists available agents
- **Agent** (various): Specialized agents that get invoked

**Why Both?**
- Hook ensures awareness of available agents
- Agents provide actual functionality
- Hook enables agent discovery

## When to Use All Three

Sometimes you need agent + skill + hook:

**Example: Code Quality Workflow**
- **Hook** (`pre-commit-reminder`): Reminds about quality checks before commit
- **Agent** (`code-reviewer`): Performs automated code review
- **Skill** (`team-code-standards`): Project-specific conventions checklist

**Why All Three?**
- Hook triggers at the right moment (before commit)
- Agent provides automated analysis and fixes
- Skill captures project-specific rules agent may not know
- Complete workflow: reminder → automation → validation

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

### ❌ Hook Doing Too Much

**Indicators**:
- Hook script takes > 1 second to run
- Hook makes complex decisions
- Hook modifies files or state
- Hook has complex error handling

**Example**: Hook that analyzes entire codebase and generates reports
**Solution**: Convert to agent that runs on-demand

### ❌ Hook Providing Detailed Guidance

**Indicators**:
- Hook output is multiple paragraphs
- Hook provides step-by-step instructions
- Hook includes examples and patterns
- Users refer back to hook output

**Example**: Hook that outputs comprehensive testing guide
**Solution**: Create skill with detailed guide, hook can reference it

### ❌ Agent That Should Be a Hook

**Indicators**:
- Agent only injects context, doesn't execute
- Agent always runs at specific moments
- Agent output is just reminders
- No file modifications or complex logic

**Example**: Agent that lists available agents when invoked
**Solution**: Convert to SessionStart hook that discovers agents

### ❌ Slow Hook Performance

**Indicators**:
- Hook delays response time
- Hook runs complex queries
- Hook processes large files
- Users notice lag

**Example**: Hook that searches entire codebase for patterns
**Solution**: Cache results or convert to on-demand agent

## Decision Shortcuts

### Quick Yes/No Test

**Create an AGENT if ANY of these are true:**
- [ ] Must create or modify files
- [ ] Must run terminal commands for execution (not just discovery)
- [ ] Should work autonomously
- [ ] Needs to make complex decisions
- [ ] Should trigger proactively based on context

**Create a SKILL if ALL of these are true:**
- [ ] Reference guide / checklist
- [ ] Validation-focused
- [ ] Read-only / non-destructive
- [ ] Manual invocation
- [ ] Narrow, focused scope

**Create a HOOK if ALL of these are true:**
- [ ] Responds to specific Claude Code events
- [ ] Fast execution (< 1 second)
- [ ] Injects context or reminders
- [ ] No file modifications
- [ ] Simple, focused behavior

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
| Remind about parallelization | **Hook** | parallelization-reminder | Event-driven, UserPromptSubmit |
| Discover available agents | **Hook** | agent-discovery | Dynamic discovery, SessionStart |
| Project context on startup | **Hook** | session-context | Context injection, SessionStart |
| Validate before commit | **Hook** | pre-commit-checklist | Reminder, before git operations |

## Final Checklist

Before creating, verify your choice:

**Agent Checklist:**
- [ ] Purpose requires autonomous execution
- [ ] Will create, modify, or delete files OR run commands for execution
- [ ] Benefits from proactive triggering based on context
- [ ] Provides broad domain expertise
- [ ] User wants "do it for me" not "show me how"
- [ ] NOT just injecting reminders or context

**Skill Checklist:**
- [ ] Purpose is validation or reference
- [ ] Read-only analysis or guidance
- [ ] Manual invocation preferred
- [ ] Narrow, focused concern
- [ ] User wants "checklist" or "patterns to follow"
- [ ] NOT event-driven automation

**Hook Checklist:**
- [ ] Purpose is event-driven behavior
- [ ] Responds to specific Claude Code events (SessionStart, UserPromptSubmit, etc.)
- [ ] Fast execution (< 1 second ideally)
- [ ] Injects context, reminders, or performs discovery
- [ ] No file modifications (read-only)
- [ ] User wants consistent behavior across sessions
- [ ] NOT complex logic or autonomous execution

## Still Unsure?

**Default to Agent if:**
- Automation would save significant time
- Task is repetitive and well-defined
- Execution is safer than manual steps
- Complex logic or decisions required

**Default to Skill if:**
- Task requires human judgment
- Project-specific conventions involved
- Quick reference is primary need
- Safety requires manual review

**Default to Hook if:**
- Behavior should happen at specific events
- Just injecting context or reminders
- Dynamic discovery needed
- Fast, lightweight operation
- Consistent behavior desired

---

**Remember**: When in doubt, ask the user:
- "Should this run on specific Claude Code events?" → **Hook**
- "Should this run automatically or provide a checklist?" → **Agent** vs **Skill**
- "Do you want me to execute this or guide you through it?" → **Agent** vs **Skill**
- "Is this a reminder/context or execution?" → **Hook** vs **Agent**

## Hook-Specific Guidance

### When Hook is Better Than Agent

**Use Hook instead of Agent when:**
- Purpose is just to remind or inject context
- No complex decision-making needed
- Should happen at specific lifecycle moments
- Fast, simple operation
- Same behavior every time

**Example**: Instead of creating an `agent-lister` agent that lists available agents, create a SessionStart hook that discovers and displays them.

### When Agent is Better Than Hook

**Use Agent instead of Hook when:**
- Complex logic or analysis required
- File modifications needed
- Should trigger based on context, not events
- Multi-step workflow
- Adaptive behavior

**Example**: Instead of a pre-commit hook that analyzes and fixes code, create a `code-reviewer` agent that can be invoked when needed.

### Hook + Agent Combinations

**Powerful Pattern**: Hook reminds, Agent executes

**Example**:
- **Hook** (UserPromptSubmit): "Consider using parallel agents for this multi-domain task"
- **Agent** (workflow-orchestrator): Actually coordinates parallel agent execution

**Why This Works**:
- Hook provides timely context
- Agent handles complex execution
- Clear separation of concerns
- User gets reminder but maintains control
