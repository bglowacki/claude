# Global Claude Code Configuration

## Core Architecture Principles

### Dynamic Discovery
- **Agents and skills are discovered automatically** via hooks before each prompt
- **No manual lists needed** - hook scans directories and provides current roster
- **To add**: Just create .md files in `~/.claude/agents/` or `~/.claude/skills/`
- **To remove**: Delete files - automatic update

### Progressive Disclosure
- Load minimal information initially
- Reveal details only when relevant
- Keep context windows focused and efficient

### Constraint-Based Development
- Default to "minimal necessary changes"
- Challenge complexity - simpler is better
- Align with existing patterns in codebase

### Code Style Preferences
- **No docstrings**: Don't add docstrings to functions unless explicitly requested
- **Minimal changes**: Keep code changes focused on functional requirements only
- **Self-documenting code**: Prefer clear naming over documentation
- **Comments only when needed**: Add comments only for non-obvious logic or important caveats
- **No Claude attribution**: Don't add Claude Code attribution to git commits (no "Generated with Claude Code" or "Co-Authored-By: Claude")

---

## When to Use What

### Agents (Specialized Workers)
**Purpose:** Handle specific domain tasks with appropriate tools and expertise

**When to use:**
- Domain-specific implementation (backend, database, infrastructure, etc.)
- Code review and quality assurance
- Research and analysis
- Orchestration of complex workflows
- Security analysis and testing

**Selection:** Claude auto-selects based on task description matching agent triggers in roster

**Example triggers:**
- "implement authentication" → backend specialist
- "optimize PostgreSQL query" → database specialist
- "review for security issues" → security specialist

### Skills (Knowledge Containers)
**Purpose:** Provide patterns, templates, and reference guidance without execution

**When to use:**
- Need design patterns or best practices
- Reference architectures and examples
- Decision frameworks (when to use X vs Y)
- Domain knowledge without code changes

**Selection:** Use Skill tool (`@skill-name`) when you need guidance, not implementation

**Example usage:**
- "@design-domain-events" for event sourcing patterns
- "@project-instructions" for documentation guidance

### Commands (Quick Tasks)
**Purpose:** Discrete, repeatable operations

**When to use:**
- Frequent workflows you want to standardize
- Standardized procedures
- Quick references

**Selection:** Use `/command-name` syntax

---

## Agent Delegation Policy (CRITICAL)

### MUST DELEGATE - No Direct Answers Allowed

When the `discover-agents.sh` hook identifies agents as **REQUIRED** (marked with 🔴 MUST USE), you MUST delegate to them. These agents are marked as "PROACTIVE" or "auto-engages" in their descriptions, indicating specialized domain expertise or current documentation access.

**Priority Levels:**

#### 🔴 MUST USE (Non-Negotiable Delegation)
1. **Domain Specialists with PROACTIVE flag:**
   - datadog-specialist, aws-cloud-specialist, eventsourcing-expert, etc.
   - These agents have up-to-date documentation access (WebFetch, Context7 MCP)
   - ALWAYS delegate - DO NOT answer from training data
   - Example: "Set up Datadog tracing" → MUST use datadog-specialist

2. **Research/Documentation Requests:**
   - research-analyst for "how does X work", "look up docs", "best practices"
   - ALWAYS fetch current documentation via WebFetch/WebSearch
   - DO NOT provide answers from training data (may be outdated)
   - Example: "How does FastAPI handle async?" → MUST use research-analyst

3. **Auto-Engage Agents:**
   - code-reviewer (after code changes)
   - development-orchestrator (complex multi-domain tasks)
   - These trigger automatically based on context
   - Example: After implementing a feature → code-reviewer MUST review

#### 🟡 SHOULD USE (Recommended)
- Specialized agents without PROACTIVE flag
- Consider delegation for better quality
- Use judgment based on task complexity
- Can answer directly for simple queries

### Delegation Decision Tree

```
User Request
  ↓
Hook runs → Discovers agents
  ↓
┌─────────────────────────────────┐
│ Is agent marked 🔴 MUST USE?   │
└─────────────────────────────────┘
         ↓ YES                ↓ NO
         ↓                    ↓
  MUST DELEGATE          Use judgment:
  Use Task tool          - Complex → delegate
  DO NOT answer          - Simple → can answer
  directly               - Research needed → delegate
```

### When Direct Answers Are Acceptable

**You MAY answer directly ONLY when:**
- ✅ No agents were suggested by the hook
- ✅ Simple factual questions (basic concepts, definitions)
- ✅ Clarifying questions to the user
- ✅ Basic file operations using tools directly
- ✅ Questions about your own capabilities

**You MUST delegate when:**
- ❌ Hook suggests 🔴 MUST USE agents
- ❌ Research/documentation needed ("how does X work")
- ❌ Domain-specific expertise required (AWS, Datadog, PostgreSQL)
- ❌ Current/up-to-date information needed
- ❌ Code review after changes
- ❌ Complex multi-step implementations

### Correct Delegation Pattern

**Bad (Direct Answer):**
```
User: "How do I set up Datadog APM tracing in Python?"
Assistant: "To set up Datadog APM tracing, use ddtrace..."
❌ WRONG: Answered directly despite datadog-specialist being REQUIRED
```

**Good (Delegation):**
```
User: "How do I set up Datadog APM tracing in Python?"
[Hook suggests: 🔴 MUST USE datadog-specialist]
Assistant: "I'll delegate this to the datadog-specialist agent..."
<uses Task tool with subagent_type="datadog-specialist">
✅ CORRECT: Delegated to specialist with current docs access
```

### Why This Matters

**Training data limitations:**
- Your training data has a cutoff date (January 2025)
- Libraries/frameworks update frequently
- APIs change, best practices evolve
- Documentation specialists fetch CURRENT information

**Domain expertise:**
- PROACTIVE agents have specialized prompts and workflows
- They know domain-specific patterns and anti-patterns
- They apply framework-specific best practices
- They validate against official documentation

**Quality assurance:**
- Specialized agents follow rigorous validation steps
- They cross-reference multiple sources
- They provide implementation-tested solutions
- They catch domain-specific edge cases

### Enforcement

The hook system will:
1. **Pre-request:** Suggest agents with priority levels
2. **Post-request:** (Future) Validate you used suggested agents
3. **Feedback:** Warn if MUST USE agents were ignored

**Remember:** When in doubt about whether to delegate, **delegate**. Specialized agents provide higher quality, more current, and more accurate responses than general knowledge.

---

## Orchestration Patterns

### Parallel Invocation
**Key principle**: Launch multiple agents concurrently for independent tasks

**How**: Use ONE message with MULTIPLE Task tool calls

**When to parallelize:**
- Tasks are independent (no dependencies)
- Same agent processing different items (e.g., "analyze all agents")
- Different agents working on different aspects (e.g., implementation || testing)

**Benefits:**
- All agents run simultaneously (not sequential)
- Faster completion time
- Efficient resource usage

**Example patterns:**
- Multi-domain review → Parallel specialized reviewers
- Implementation + testing → Developer agent || test-automator
- Analysis across components → Parallel domain specialists

**MANDATORY PARALLELIZATION CHECKLIST:**

Before executing ANY multi-part request, you MUST explicitly state:

```
PARALLELIZATION DECISION:
- Can tasks run independently? [YES/NO]
- If YES: Executing [N] agents in PARALLEL: [agent1, agent2, ...]
- If NO: Sequential because: [specific dependency reason]
```

This is **NOT optional** - it forces deliberate thinking about execution strategy.

### Sequential Workflows
**When**: Tasks have dependencies - one needs output from another

**How**: Chain agents with clear handoffs

**Example workflow:**
1. Analysis agent examines codebase
2. Planning agent creates implementation strategy
3. Implementation agent executes changes
4. Quality agent validates results

### Complex Multi-Phase Workflows
**When to use development-orchestrator:**
- Task requires 3+ different specialized agents (not just repeating one)
- Sequential dependencies between phases
- Mixed parallel and sequential execution
- Quality gates needed (tests, docs, deployment)

**Examples:**
- "Implement feature X with tests, documentation, and deployment"
- "Refactor module Y, update all dependents, run tests, and create PR"
- "Audit security, fix issues, add tests, update docs"

**NOT for:**
- Simple batch operations on similar items ("analyze all agents")
- Single-agent repeated invocations
- Straightforward "process all X" requests

---

## Best Practices

### Constraint-Based Prompting
**Default template:**
```
Task: [specific goal]
Constraints:
- Minimal necessary changes only
- Use existing patterns from [specific files]
- Single file modification if possible
- No new dependencies

Plan first, confirm before implementation.
```

**Why this works:**
- Prevents over-engineering
- Maintains consistency
- Reduces cognitive load
- Faster implementation

### Context Management
**Aggressive hygiene required:**
- Use `/clear` after completing each discrete task
- Run `git status` before commits, clean artifacts
- Start fresh sessions for major refactoring
- Set 30-minute session boundaries

**Quality over quantity:**
- 10% context with relevant info beats 100% with noise
- Compaction is expensive - avoid by clearing proactively
- Post-compaction degradation is real - start fresh when needed

### Test-Driven Development
**Standard workflow:**
1. Write tests first (with Claude)
2. **Verify tests fail** (no mock implementations)
3. Commit tests
4. Implement code to pass
5. Verify with subagent

**Critical:** Guard test files - Claude may modify tests to match wrong implementations rather than fixing code

### Batch Operations Pattern

**For simple batch operations:**
1. **Identify Items**: Use Glob/Grep to discover all items
2. **Select Agent**: Determine which specialized agent handles each item
3. **Parallel Invocation**: Launch multiple Task tool calls in ONE message
4. **Aggregate Results**: Collect and summarize findings

**Example:**
- User: "analyze all agents for best practices"
- Approach: Glob for `~/.claude/agents/*.md`, launch toolkit-manager for each in parallel

### Planning Complex Tasks
**For multi-step development tasks:**
1. **Plan first**: Use TodoWrite to break down the work
2. **Identify phases**: Determine which parts can be parallel vs sequential
3. **Select agents**: Match each task to appropriate specialist (check roster)
4. **Execute efficiently**: Parallel where possible, sequential where necessary
5. **Aggregate and verify**: Collect results and ensure quality

---

## Working with This Configuration

### Agent Roster
**Discovered dynamically by hook** - check hook output before each prompt for current list

**Categories typically include:**
- Development specialists (language/framework specific)
- Infrastructure specialists (databases, cloud, containers)
- Quality specialists (testing, review, security)
- Architecture specialists (design, patterns, APIs)
- Meta specialists (toolkit management, orchestration)

### Skill Roster
**Discovered dynamically by hook** - check hook output for current list

**Typically focused on:**
- Domain-specific patterns and practices
- Reference architectures
- Decision frameworks

### Adding Your Own
**Agents:** Create `~/.claude/agents/new-agent.md` with YAML frontmatter
**Skills:** Create `~/.claude/skills/new-skill/SKILL.md` with YAML frontmatter
**Both auto-discovered** on next prompt - no documentation updates needed

---

## Project-Specific Conventions

When working in specific projects, project-local agents and skills can be created in:
- `./.claude/agents/` for project-specific agents
- `./.claude/skills/` for project-specific skills

These will be marked with "(local)" suffix in the roster.

---

## External References

For detailed patterns and workflows, see:
- Parallel invocation examples: `@./docs/patterns/parallel-invocation.md` (when created)
- Constraint templates: `@./docs/patterns/constraints.md` (when created)
- Workflow examples: `@./docs/workflows/` (when created)
