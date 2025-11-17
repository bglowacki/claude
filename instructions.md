# Claude Code Custom Instructions

## Batch Operations Pattern

When handling requests involving multiple items (keywords: "all", "multiple", "every"):

### Standard Approach for Simple Batch Operations

1. **Identify Items**: Use Glob/Grep to discover all items
2. **Select Agent**: Determine which specialized agent handles each item
3. **Parallel Invocation**: Launch multiple Task tool calls in a SINGLE message
4. **Aggregate Results**: Collect and summarize findings

### Example Pattern

**User request**: "analyze all agents for best practices"

**Correct approach**:
1. Use Glob to find all agent files: `~/.claude/agents/*.md`
2. Identify toolkit-manager as the appropriate agent
3. Launch multiple Task invocations in ONE message (all parallel)
4. Aggregate results and report patterns

**DO NOT** delegate to workflow-orchestrator for simple batch operations like this.

### When to Use workflow-orchestrator

Reserve workflow-orchestrator ONLY for complex multi-phase workflows that require:
- **3+ different specialized agents** (not just repeating one agent)
- **Sequential dependencies** between phases
- **Mixed parallel and sequential execution**

**Examples of complex workflows**:
- "Implement feature X with tests, documentation, and deployment"
- "Refactor module Y, update all dependents, run tests, and create PR"
- "Audit security, fix issues, add tests, update docs"

**NOT for**:
- Simple batch operations on similar items
- Single-agent repeated invocations
- Straightforward "process all X" requests

### Parallel Task Invocation Best Practices

**Key principle**: To invoke multiple agents in parallel, make multiple Task tool calls in a **single response message**.

**Benefits**:
- All agents run simultaneously (not sequential)
- Faster completion time
- Efficient resource usage
- Better user experience

**When to parallelize**:
- Tasks are independent (no dependencies between them)
- Same agent type processing different items
- Different agents working on different aspects

**When NOT to parallelize**:
- Tasks have dependencies (one needs output from another)
- Sequential execution required by nature of work
- Risk of conflicts (e.g., editing same file)

## Complex Workflow Guidelines

For multi-step development tasks:

1. **Plan first**: Use TodoWrite to break down the work
2. **Identify phases**: Determine which parts can be parallel vs sequential
3. **Select agents**: Match each task to the appropriate specialized agent
4. **Execute efficiently**: Parallel where possible, sequential where necessary
5. **Aggregate and verify**: Collect results and ensure quality

## Agent Selection Guidelines

- **toolkit-manager**: Agent/skill creation, analysis, and management
- **code-reviewer**: Code quality, security, best practices validation
- **architect-reviewer**: System design, DDD, architectural decisions
- **test-automator**: Test framework design and implementation
- **debugger**: Complex issue diagnosis and troubleshooting
- **workflow-orchestrator**: Complex multi-phase workflows only

Choose the most specific agent for each task. Don't over-engineer simple requests.
