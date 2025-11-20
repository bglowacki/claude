# Tool Restrictions in Skills

Tool restrictions allow you to limit which tools a skill can use, providing safety guardrails and enforcing best practices.

## Why Restrict Tools?

### Safety
Prevent accidental destructive operations:
- **Analysis skills**: Read-only access prevents modifying code during investigation
- **Review skills**: No writes ensures reviews don't auto-fix issues
- **Research skills**: Limit to search tools prevents unintended changes

### Performance
Reduce unnecessary operations:
- **Search skills**: Only Grep/Glob, no file modifications
- **Planning skills**: Read-only, execution happens separately
- **Validation skills**: Check-only, no fixes

### Clarity
Make skill purpose explicit:
- Tools reveal intent (read-only = analysis, full access = implementation)
- Users understand limitations upfront
- Prevents scope creep

## How to Restrict Tools

Add `allowed-tools` to YAML frontmatter:

```yaml
---
name: Code Analyzer
description: Analyzes code quality without making changes
allowed-tools: [Read, Grep, Glob]
---
```

**Without restrictions:**
```yaml
---
name: Feature Implementer
description: Implements new features with full access
# No allowed-tools = all tools available
---
```

## Common Tool Restriction Patterns

### Pattern 1: Read-Only Analysis
**Use case**: Code review, security audit, architecture analysis

```yaml
allowed-tools: [Read, Grep, Glob]
```

**Available capabilities:**
- ✅ Read files
- ✅ Search content
- ✅ Find files by pattern
- ❌ Modify files
- ❌ Execute commands
- ❌ Create files

**Example skills:**
- Security vulnerability scanner
- Code complexity analyzer
- Dependency auditor
- Architecture reviewer

### Pattern 2: Search + Basic Execution
**Use case**: Testing, validation, CI checks

```yaml
allowed-tools: [Read, Grep, Glob, Bash]
```

**Available capabilities:**
- ✅ Read files
- ✅ Search content
- ✅ Run commands (tests, linters)
- ❌ Modify files
- ❌ Create files

**Example skills:**
- Test runner
- Linter executor
- Build validator
- Performance benchmarker

### Pattern 3: Read + Write (No Execution)
**Use case**: Documentation, code generation from templates

```yaml
allowed-tools: [Read, Write, Edit, Grep, Glob]
```

**Available capabilities:**
- ✅ Read files
- ✅ Write/edit files
- ✅ Search content
- ❌ Execute commands
- ❌ Run arbitrary scripts

**Example skills:**
- Documentation generator
- Code template expander
- Configuration file generator
- Schema validator with auto-fix

### Pattern 4: Full Implementation Access
**Use case**: Feature implementation, refactoring, deployment

```yaml
# No allowed-tools restriction
```

**Available capabilities:**
- ✅ All tools available
- ✅ Read, write, edit files
- ✅ Execute commands
- ✅ Deploy changes
- ✅ Modify infrastructure

**Example skills:**
- Feature implementer
- Database migrator
- Deployment manager
- Full-stack developer

## Tool Reference

### File Access Tools
| Tool | Capability | Common Use |
|------|-----------|------------|
| `Read` | Read file contents | Loading code, config, docs |
| `Write` | Create/overwrite files | Generating new files |
| `Edit` | Modify existing files | Updating code, fixing issues |
| `Glob` | Find files by pattern | Locating specific file types |
| `Grep` | Search file contents | Finding code patterns, text |

### Execution Tools
| Tool | Capability | Common Use |
|------|-----------|------------|
| `Bash` | Run shell commands | Tests, builds, git, deployments |
| `Task` | Launch sub-agents | Complex multi-step tasks |

### Specialized Tools
| Tool | Capability | Common Use |
|------|-----------|------------|
| `WebFetch` | Fetch web content | API docs, external resources |
| `WebSearch` | Search the web | Research, documentation lookup |
| `AskUserQuestion` | Prompt user input | Gathering requirements, decisions |
| `TodoWrite` | Manage task list | Planning, progress tracking |

### MCP Tools
MCP (Model Context Protocol) tools are server-specific and vary by installation. Common examples:
- `mcp__pycharm__*`: PyCharm IDE integration tools
- `mcp__context7__*`: Documentation lookup tools
- `mcp__youtube-transcript__*`: YouTube transcript extraction

**Note**: MCP tools are available only if the MCP server is installed and running.

## Decision Matrix: Which Tools to Allow?

| Skill Purpose | Recommended Tools | Rationale |
|---------------|-------------------|-----------|
| **Analyze code quality** | `[Read, Grep, Glob]` | Read-only prevents changes during analysis |
| **Search codebase** | `[Grep, Glob]` | Only search capabilities needed |
| **Review security** | `[Read, Grep, Glob]` | Audit without modification |
| **Run tests** | `[Read, Grep, Glob, Bash]` | Need to execute test commands |
| **Generate docs** | `[Read, Write, Edit, Grep, Glob]` | Create/update files, no execution |
| **Implement features** | All tools | Full access for implementation |
| **Deploy infrastructure** | All tools | Need execution + file modification |
| **Refactor code** | All tools | Write code + run tests to verify |
| **Validate configuration** | `[Read, Grep, Glob, Bash]` | Check validity by running validators |
| **Research best practices** | `[Read, Grep, Glob, WebFetch, WebSearch]` | Read code + fetch external docs |

## Examples

### Example 1: Security Auditor (Restricted)

```yaml
---
name: OWASP Security Auditor
description: |
  Audits code for OWASP Top 10 vulnerabilities without making changes.
  Use this when: reviewing code for security issues or before production deployment.
allowed-tools: [Read, Grep, Glob]
---

# Instructions

## Workflow
1. **Scan for SQL Injection**: Search for unsafe query construction
2. **Check XSS Protection**: Verify output escaping
3. **Validate Authentication**: Review auth implementation
4. **Report Findings**: List vulnerabilities with severity

**Rationale for restrictions:**
- Read-only ensures audit integrity
- No modifications during security review
- Findings presented for manual remediation
```

**Why restrict?**
- Security audits should not auto-fix issues
- Maintains separation between detection and remediation
- Prevents accidental code changes during review

### Example 2: Test Runner (Partial Restriction)

```yaml
---
name: Pytest Test Runner
description: |
  Runs pytest tests and reports results without modifying code.
  Use this when: validating code changes or in CI/CD pipelines.
allowed-tools: [Read, Grep, Glob, Bash]
---

# Instructions

## Workflow
1. **Locate Tests**: Find all test files using Glob
2. **Run Pytest**: Execute `pytest` with appropriate flags
3. **Analyze Results**: Parse output for failures
4. **Report Coverage**: Show coverage metrics

**Rationale for restrictions:**
- Bash needed to run pytest command
- Read/Grep/Glob for locating tests and analyzing results
- No Write/Edit prevents auto-fixing failing tests
```

**Why restrict?**
- Test runners should only execute tests, not modify them
- Prevents skill from "fixing" tests to make them pass
- Clear separation: run tests here, fix code elsewhere

### Example 3: OpenAPI Generator (Write-Only Restriction)

```yaml
---
name: OpenAPI Schema Generator
description: |
  Generates OpenAPI schema from Django endpoints.
  Use this when: API endpoints change or schema needs updating.
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash]
---

# Instructions

## Workflow
1. **Scan Endpoints**: Find all ViewSet and APIView classes
2. **Generate Schema**: Run `python manage.py generate_openapi`
3. **Validate Schema**: Verify OpenAPI 3.0 compliance
4. **Update Files**: Write schema to static directory

**Rationale for restrictions:**
- Read/Grep/Glob for finding endpoints
- Bash for running schema generation command
- Write/Edit for updating schema files
- Full access appropriate for generation task
```

**Why allow full access?**
- Schema generation needs file modification
- Command execution required for generation
- Output needs to be written to specific locations

### Example 4: Code Complexity Analyzer (Read-Only)

```yaml
---
name: Code Complexity Analyzer
description: |
  Analyzes cyclomatic complexity and suggests refactoring targets.
  Use this when: identifying complex code or planning refactoring.
allowed-tools: [Read, Grep, Glob]
---

# Instructions

## Workflow
1. **Scan Codebase**: Find all Python files
2. **Analyze Functions**: Calculate complexity metrics
3. **Identify Hotspots**: Find functions with high complexity
4. **Recommend Refactoring**: Suggest simplification targets

**Rationale for restrictions:**
- Read-only analysis prevents accidental changes
- No Bash needed (complexity calculated programmatically)
- Recommendations presented for manual refactoring
```

**Why restrict?**
- Analysis should not modify code
- Metrics calculated from file content, no execution needed
- Clear intent: analyze only, don't fix

## Best Practices

### DO: Match Restrictions to Purpose
✅ **Analysis skills**: Use read-only tools
✅ **Implementation skills**: Allow full access
✅ **Validation skills**: Read + execution, no writes
✅ **Generation skills**: Read + write, execution if needed

### DON'T: Over-Restrict
❌ **Bad**: Requiring Bash but not allowing it
❌ **Bad**: Expecting file writes but only allowing Read
❌ **Bad**: Restricting tools that are essential for the task

### DO: Document Restrictions
✅ Include rationale in skill documentation:
```markdown
**Tool Restrictions**: Read, Grep, Glob only

**Rationale**: This skill analyzes code without making changes,
ensuring audit integrity and preventing accidental modifications.
```

### DON'T: Restrict Just Because
❌ **Bad**: Restricting tools without clear reason
❌ **Bad**: Copy-pasting restrictions from other skills
❌ **Bad**: Restricting out of caution without understanding impact

### DO: Test with Restrictions
✅ Verify skill works with the allowed tools
✅ Ensure no essential capabilities are blocked
✅ Confirm restrictions achieve desired safety goals

### DON'T: Assume Restrictions Work
❌ **Bad**: Setting restrictions without testing
❌ **Bad**: Assuming users will understand limitations
❌ **Bad**: Not documenting what's blocked and why

## Common Pitfalls

### Pitfall 1: Forgetting Bash for Test Execution
**Problem**: Skill needs to run tests but `allowed-tools: [Read, Grep, Glob]`
**Solution**: Add `Bash` to run test commands

### Pitfall 2: Blocking Necessary File Edits
**Problem**: Skill should update config but only has `Read`
**Solution**: Add `Write` or `Edit` as appropriate

### Pitfall 3: Over-Restricting Implementation Skills
**Problem**: Feature implementation skill with `allowed-tools: [Read, Write]` (no Bash)
**Solution**: Remove restrictions for implementation skills (need tests, git, etc.)

### Pitfall 4: Inconsistent Restrictions
**Problem**: Similar skills have different restrictions without reason
**Solution**: Standardize restrictions for skill categories

### Pitfall 5: No Explanation of Restrictions
**Problem**: Users confused why skill is limited
**Solution**: Document rationale in skill instructions

## Validation Checklist

Before finalizing tool restrictions:

**Functional Validation:**
- [ ] Skill can complete its primary task with allowed tools
- [ ] No essential capabilities are blocked
- [ ] Restrictions don't prevent legitimate use cases

**Safety Validation:**
- [ ] Restrictions prevent unintended modifications (if that's the goal)
- [ ] Read-only skills can't accidentally change files
- [ ] Execution-restricted skills can't run dangerous commands

**Documentation Validation:**
- [ ] Restrictions are documented in frontmatter
- [ ] Rationale is explained in instructions
- [ ] Users understand what's blocked and why
- [ ] Examples show what can and can't be done

**Testing Validation:**
- [ ] Skill tested with restrictions in place
- [ ] Edge cases validated (what happens when blocked tool is needed?)
- [ ] User experience verified (clear errors if restriction hit)

## Advanced: Dynamic Tool Selection

For complex skills that need different tools in different phases:

**Option 1: Split into Multiple Skills**
```
skill-analyze/              # allowed-tools: [Read, Grep, Glob]
skill-implement/            # No restrictions
skill-validate/             # allowed-tools: [Read, Bash]
```

**Option 2: Phase-Based Documentation**
```markdown
## Phase 1: Analysis (Read-Only)
Use Read, Grep, Glob to analyze the codebase...

## Phase 2: Implementation (Full Access)
Now implement the changes with full tool access...

Note: This skill requires full tool access for Phase 2.
```

**Recommendation**: Split into focused skills rather than one multi-phase skill.

---

## Summary

| Aspect | Guidance |
|--------|----------|
| **Purpose** | Safety, performance, clarity |
| **Implementation** | Use `allowed-tools` in YAML frontmatter |
| **Read-Only** | `[Read, Grep, Glob]` for analysis/review |
| **Execution** | Add `Bash` for running commands |
| **Modification** | Add `Write`, `Edit` for file changes |
| **Full Access** | Omit `allowed-tools` for implementation |
| **Documentation** | Always explain why tools are restricted |
| **Testing** | Verify skill works with restrictions |

**Key Principle**: Restrict tools when it adds safety or clarity, not by default.
