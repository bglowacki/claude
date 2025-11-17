# Tool Selection Guide

Comprehensive guide for choosing the right tools for your Claude Code agent.

## Available Tools

### File Access Tools

**Read**
- **Purpose**: Read file contents
- **Use when**: Agent needs to analyze code, configs, or documentation
- **Restrictions**: None - safe for all agents
- **Common patterns**: Code analysis, documentation lookup, config validation

**Write**
- **Purpose**: Create new files or overwrite existing ones
- **Use when**: Agent generates new code, configs, or documentation
- **Restrictions**: Destructive - use `disallowedTools` for read-only agents
- **Common patterns**: Code generation, documentation creation, config file generation

**Edit**
- **Purpose**: Modify existing files with targeted changes
- **Use when**: Agent updates specific parts of files without rewriting
- **Restrictions**: Destructive - use `disallowedTools` for read-only agents
- **Common patterns**: Code refactoring, bug fixes, incremental updates

### Search Tools

**Grep**
- **Purpose**: Search file contents with regex patterns
- **Use when**: Agent needs to find specific code patterns or text
- **Restrictions**: None - safe for all agents
- **Common patterns**: Finding function definitions, locating config values, pattern matching

**Glob**
- **Purpose**: Find files by name patterns
- **Use when**: Agent needs to locate files matching specific patterns
- **Restrictions**: None - safe for all agents
- **Common patterns**: Finding all test files, locating configs, identifying source files

### Execution Tools

**Bash**
- **Purpose**: Execute shell commands
- **Use when**: Agent needs to run tests, build tools, or system commands
- **Restrictions**: Powerful - consider `disallowedTools` for analysis-only agents
- **Common patterns**: Running tests, executing builds, git operations, package management

**Task**
- **Purpose**: Launch specialized sub-agents for complex tasks
- **Use when**: Agent needs to delegate to other specialized agents
- **Restrictions**: Advanced - typically for orchestration agents
- **Common patterns**: Multi-agent workflows, complex orchestration, specialized delegation

### Web Access Tools

**WebFetch**
- **Purpose**: Fetch content from URLs for processing
- **Use when**: Agent needs to retrieve documentation, API responses, or web content
- **Restrictions**: Requires network - may fail in offline environments
- **Common patterns**: Fetching docs, API documentation lookup, external resource retrieval

**WebSearch**
- **Purpose**: Search the web for information
- **Use when**: Agent needs to research topics or find current information
- **Restrictions**: Requires network, US-only, consumes tokens
- **Common patterns**: Research, trend analysis, best practice lookup

### Specialized Tools

**NotebookEdit**
- **Purpose**: Edit Jupyter notebook cells
- **Use when**: Agent works with .ipynb files
- **Restrictions**: Specific to notebooks
- **Common patterns**: Data science workflows, notebook-based tutorials

**TodoWrite**
- **Purpose**: Manage task lists and track progress
- **Use when**: Agent orchestrates multi-step workflows
- **Restrictions**: UI-dependent - may not work in all environments
- **Common patterns**: Project planning, progress tracking, workflow management

**AskUserQuestion**
- **Purpose**: Prompt user for clarification or decisions
- **Use when**: Agent needs user input during execution
- **Restrictions**: Blocks execution until user responds
- **Common patterns**: Gathering requirements, confirming actions, choice selection

---

## Tool Combination Patterns

### Pattern 1: Read-Only Analysis
**Tools**: `[Read, Grep, Glob]`
**DisallowedTools**: `[Write, Edit, Bash]`

**Use for:**
- Code reviewers
- Security auditors
- Architecture analyzers
- Documentation validators
- Complexity analyzers

**Rationale**: Prevents accidental modifications during analysis, ensuring audit integrity.

**Example:**
```yaml
tools: [Read, Grep, Glob]
disallowedTools: [Write, Edit, Bash]
```

### Pattern 2: Analysis with Execution
**Tools**: `[Read, Grep, Glob, Bash]`
**DisallowedTools**: `[Write, Edit]`

**Use for:**
- Test runners
- Build validators
- Linters/formatters (when they don't auto-fix)
- Performance benchmarkers

**Rationale**: Can execute commands but can't modify source files.

**Example:**
```yaml
tools: [Read, Grep, Glob, Bash]
disallowedTools: [Write, Edit]
```

### Pattern 3: Code Generation (No Execution)
**Tools**: `[Read, Write, Edit, Grep, Glob]`
**DisallowedTools**: `[Bash]`

**Use for:**
- Code generators
- Template expanders
- Documentation writers (when not needing validation)
- Configuration creators

**Rationale**: Can create/modify files but can't execute potentially dangerous commands.

**Example:**
```yaml
tools: [Read, Write, Edit, Grep, Glob]
disallowedTools: [Bash]
```

### Pattern 4: Full Implementation
**Tools**: `[Read, Write, Edit, Bash, Grep, Glob]`

**Use for:**
- Feature implementers
- Refactoring specialists
- Test generators (need to run tests)
- Database migrators
- Deployment managers

**Rationale**: Needs complete access to implement, test, and validate.

**Example:**
```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob]
```

### Pattern 5: Documentation Specialist
**Tools**: `[Read, Write, WebFetch, Grep, Glob]`
**DisallowedTools**: `[Bash, Edit]`

**Use for:**
- API documentation generators
- README writers
- OpenAPI schema creators
- Technical writers

**Rationale**: Needs to fetch external docs but doesn't need to execute commands or edit code.

**Example:**
```yaml
tools: [Read, Write, WebFetch, Grep, Glob]
disallowedTools: [Bash, Edit]
```

### Pattern 6: Research Specialist
**Tools**: `[Read, Grep, Glob, WebFetch, WebSearch]`
**DisallowedTools**: `[Write, Edit, Bash]`

**Use for:**
- Research analysts
- Best practice finders
- Trend analyzers
- Technology evaluators

**Rationale**: Read-only with web access for information gathering.

**Example:**
```yaml
tools: [Read, Grep, Glob, WebFetch, WebSearch]
disallowedTools: [Write, Edit, Bash]
```

### Pattern 7: Infrastructure Manager
**Tools**: `[Read, Write, Edit, Bash, Grep, Glob, WebFetch]`

**Use for:**
- Kubernetes specialists
- CI/CD managers
- Docker orchestrators
- Cloud infrastructure managers

**Rationale**: Needs file modification, command execution, and documentation fetching.

**Example:**
```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob, WebFetch]
```

---

## Decision Tree

```
What does the agent need to do?
│
├─ Only analyze/review code?
│  └─> Tools: [Read, Grep, Glob]
│     DisallowedTools: [Write, Edit, Bash]
│
├─ Run commands but not modify files?
│  └─> Tools: [Read, Grep, Glob, Bash]
│     DisallowedTools: [Write, Edit]
│
├─ Generate/modify files but not execute?
│  └─> Tools: [Read, Write, Edit, Grep, Glob]
│     DisallowedTools: [Bash]
│
├─ Implement features (write + test)?
│  └─> Tools: [Read, Write, Edit, Bash, Grep, Glob]
│
├─ Create documentation from web sources?
│  └─> Tools: [Read, Write, WebFetch, Grep, Glob]
│     DisallowedTools: [Bash]
│
├─ Research without modifying anything?
│  └─> Tools: [Read, Grep, Glob, WebFetch, WebSearch]
│     DisallowedTools: [Write, Edit, Bash]
│
└─ Infrastructure/deployment work?
   └─> Tools: [Read, Write, Edit, Bash, Grep, Glob, WebFetch]
```

---

## Safety Considerations

### When to Use disallowedTools

**Scenario 1: Analysis-Only Agents**
```yaml
disallowedTools: [Write, Edit, Bash]
```
Prevents accidental modifications during review/analysis.

**Scenario 2: Documentation-Only Agents**
```yaml
disallowedTools: [Bash]
```
Can create/update docs but can't execute potentially dangerous commands.

**Scenario 3: Read-Execute Only**
```yaml
disallowedTools: [Write, Edit]
```
Can run tests/validation but can't modify source.

### Security Best Practices

1. **Principle of Least Privilege**: Only grant tools actually needed
2. **Explicit Restrictions**: Use `disallowedTools` for clarity
3. **Review Agents**: Should never have Write/Edit access
4. **Test Agents**: Need Bash but consider if Write/Edit needed
5. **Research Agents**: Should typically be read-only

---

## Tool Requirement Checklist

Before finalizing tool selection, verify:

**Functional Requirements:**
- [ ] Agent can complete primary task with selected tools
- [ ] No essential capabilities are blocked
- [ ] Tool combination supports workflow

**Safety Requirements:**
- [ ] Analysis agents don't have Write/Edit access
- [ ] Read-only agents have appropriate disallowedTools
- [ ] Bash access is justified (needed for execution)

**Efficiency Requirements:**
- [ ] No unnecessary tools included
- [ ] Tool set is minimal but sufficient
- [ ] WebFetch/WebSearch only if external data needed

**Testing Requirements:**
- [ ] Agent tested with tool restrictions in place
- [ ] Edge cases validated (what if tool needed but blocked?)
- [ ] User experience verified (clear errors if restricted)

---

## Common Mistakes

### Mistake 1: Over-Permissive Tools
❌ **Bad:**
```yaml
tools: [Read, Write, Edit, Bash, Grep, Glob, WebFetch, WebSearch, Task, TodoWrite]
```
Grants everything "just in case"

✅ **Good:**
```yaml
tools: [Read, Grep, Glob]
```
Only what's actually needed

### Mistake 2: Forgetting Bash for Test Execution
❌ **Bad:**
```yaml
tools: [Read, Write, Grep, Glob]
# How will tests run?
```

✅ **Good:**
```yaml
tools: [Read, Write, Bash, Grep, Glob]
# Can run pytest/npm test
```

### Mistake 3: Allowing Write for Analysis
❌ **Bad:**
```yaml
tools: [Read, Write, Edit, Grep, Glob]
# Analysis agent shouldn't modify files
```

✅ **Good:**
```yaml
tools: [Read, Grep, Glob]
disallowedTools: [Write, Edit, Bash]
```

### Mistake 4: Missing WebFetch for Doc Generation
❌ **Bad:**
```yaml
tools: [Read, Write, Grep, Glob]
# Can't fetch API documentation
```

✅ **Good:**
```yaml
tools: [Read, Write, WebFetch, Grep, Glob]
# Can fetch and incorporate external docs
```

### Mistake 5: No Safety Restrictions
❌ **Bad:**
```yaml
tools: [Read, Grep, Glob]
# No explicit disallowedTools - intent unclear
```

✅ **Good:**
```yaml
tools: [Read, Grep, Glob]
disallowedTools: [Write, Edit, Bash]
# Clearly read-only
```

---

## MCP Tools

Model Context Protocol (MCP) tools are server-specific and vary by installation.

### Common MCP Tools

**PyCharm Integration** (`mcp__pycharm__*`):
- File operations optimized for IDEs
- Project structure navigation
- Refactoring operations
- Run configuration execution

**Context7** (`mcp__context7__*`):
- Library documentation lookup
- API reference fetching
- Code example retrieval

**YouTube Transcript** (`mcp__youtube-transcript__*`):
- Extract transcripts from videos
- Useful for learning/research agents

### When to Use MCP Tools

**Use MCP tools when:**
- Specific integration is available and beneficial
- Tool provides capabilities not in standard set
- Performance is better than alternatives
- Integration is explicitly required

**Don't use MCP tools when:**
- Standard tools suffice
- MCP server availability is uncertain
- Cross-environment compatibility needed
- Agent should work without specific setup

**Example with MCP:**
```yaml
tools: [Read, Write, Edit, Grep, Glob, mcp__pycharm__get_file_problems]
```

---

## Summary Table

| Agent Purpose | Recommended Tools | DisallowedTools |
|---------------|------------------|-----------------|
| Code Review | Read, Grep, Glob | Write, Edit, Bash |
| Security Audit | Read, Grep, Glob | Write, Edit, Bash |
| Test Generation | Read, Write, Bash, Grep, Glob | - |
| Test Runner | Read, Bash, Grep, Glob | Write, Edit |
| Feature Implementation | Read, Write, Edit, Bash, Grep, Glob | - |
| Documentation | Read, Write, WebFetch, Grep, Glob | Bash |
| Research | Read, Grep, Glob, WebFetch, WebSearch | Write, Edit, Bash |
| Refactoring | Read, Write, Edit, Bash, Grep, Glob | - |
| Infrastructure | Read, Write, Edit, Bash, Grep, Glob | - |
| Debugging | Read, Bash, Grep, Glob | Write, Edit |

**Key Principle**: Start minimal, add tools only when necessary, restrict for safety.
