# Personal Claude Code Global Configuration

**Location:** `~/.claude/` (applies to ALL projects)

## Overview

This directory contains my personal Claude Code configuration that applies globally across all projects. The architecture emphasizes dynamic discovery and minimal maintenance - agents and skills are discovered automatically, requiring zero manual documentation updates.

## Architecture

### Dynamic Discovery
- **Agents:** Auto-discovered from `~/.claude/agents/` and `./.claude/agents/`
- **Skills:** Auto-discovered from `~/.claude/skills/` and `./.claude/skills/`
- **Hook:** `discover-agents.sh` scans directories before each prompt
- **Zero maintenance** - add/remove by creating/deleting files

### Configuration Files
- `settings.json` - Global hooks, plugins, status line configuration
- `settings.local.json` - Personal permissions and security settings
- `CLAUDE.md` - Conceptual guidance (patterns, not inventories)
- `README.md` - This file

## Directory Structure

```
~/.claude/
├── README.md              # This file
├── CLAUDE.md             # Conceptual guidance
├── settings.json         # Global configuration
├── settings.local.json   # Personal permissions (git-ignored)
├── agents/               # Global agents (25+ currently)
│   ├── *.md             # Agent definitions
│   └── toolkit-manager/ # Supporting documentation
├── skills/               # Global skills (5+ currently)
│   └── */SKILL.md       # Skill definitions
├── hooks/                # Hook scripts
│   └── discover-agents.sh  # Dynamic discovery
├── docs/                 # Modular documentation (optional)
│   ├── patterns/
│   └── workflows/
└── todos/                # Agent-generated task lists
    └── archive/          # Archived old todos
```

### Project-Specific Configuration
When in a project directory:
```
./
└── .claude/              # Project overrides
    ├── agents/           # Project-local agents (marked with "(local)")
    ├── skills/           # Project-local skills (marked with "(local)")
    └── settings.json     # Project-specific settings
```

## How to Use

### Adding New Agents
1. Create `~/.claude/agents/new-agent.md`
2. Include YAML frontmatter:
   ```yaml
   ---
   name: agent-name
   description: "When to use this agent (trigger-rich)"
   tools: "Comma-separated tool list"
   model: "sonnet | opus | haiku"
   ---
   ```
3. Hook auto-discovers on next prompt
4. **No documentation updates needed** - fully automatic

### Adding New Skills
1. Create directory: `~/.claude/skills/new-skill/`
2. Create `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: "What this skill provides"
   allowed-tools: "Optional tool restrictions"
   ---
   ```
3. Hook auto-discovers on next prompt
4. **No documentation updates needed** - fully automatic

### Project-Specific Customization
Create `./.claude/` in project root for project-specific agents/skills that only apply to that project.

## Current Configuration

### Agents
**Discovered dynamically** - see hook output for current roster

**Categories:**
- **Development:** backend-developer, python-pro, django-developer
- **Infrastructure:** kubernetes-specialist, aws-cloud-specialist, postgres-pro
- **Quality:** code-reviewer, test-automator, qa-expert, debugger
- **Architecture:** microservices-architect, api-designer
- **Productivity:** task-distributor, context-manager, documentation-engineer
- **Research:** research-analyst, trend-analyst
- **Meta:** toolkit-manager, claude-specialist, development-orchestrator
- **GitHub:** github-installation-specialist

**Total:** 25+ agents, all auto-discovered

### Skills
**Discovered dynamically** - see hook output for current roster

**Focus areas:**
- Event sourcing and domain-driven design
- Project documentation and instructions
- Design patterns and best practices

**Total:** 5+ skills, all auto-discovered

### Plugins (36 Enabled)
- **Database tools (8):** Index advisor, deadlock detector, health monitor, transaction monitor, partition manager, migration manager, backup automator
- **API tools (8):** REST generator, GraphQL builder, documentation generator, security scanner, versioning manager, schema validator, contract generator, mock server
- **Testing (12):** Unit test generator, integration runner, E2E framework, coverage analyzer, mutation tester, contract validator, performance suite, security scanner, API automation, chaos toolkit, visual regression, accessibility scanner
- **AI/ML (1):** Engineering pack
- **Specialized (7):** AI commit generator, agent context manager, application profiler, bottleneck detector, prompt improver

### Hooks
- **discover-agents.sh** (UserPromptSubmit):
  - Discovers all agents from global and project-local directories
  - Discovers all skills from global and project-local directories
  - Outputs parallelization analysis guidance
  - Provides current agent and skill rosters

### Permissions
**Allow:**
- WebFetch for documentation domains (GitHub, AWS, Python, Kubernetes, Django, Anthropic, etc.)
- WebSearch for research
- Limited Bash commands (plugin management, safe operations)
- Read access to home directory

**Deny:**
- Sensitive files (.env*, secrets/**, ~/.ssh/**, ~/.aws/**)
- System directories (/etc/**)
- Destructive operations (rm -rf, sudo rm, chmod 777)

**Ask:**
- Version control push operations (git push)
- File removal (rm)
- Network operations (curl, wget)

## Best Practices

### Core Principles (from CLAUDE.md)

1. **Dynamic over static** - Discover what exists rather than maintain lists
2. **Conceptual over inventory** - Document patterns, not catalogs
3. **Global over local** - Personal configuration applies everywhere
4. **Minimal over complex** - Simplicity and maintainability first
5. **Constraint-based development** - "Minimal necessary changes"

### Using Agents
- Let Claude auto-select based on task description
- Check hook output for current agent roster
- Use parallel invocation for independent tasks (ONE message, MULTIPLE Task calls)
- Use development-orchestrator for complex multi-phase workflows only

### Using Skills
- Use `@skill-name` syntax to activate
- Skills provide patterns and guidance (read-only)
- Agents provide implementation (read-write)
- Consult skills for design decisions, use agents for execution

### Context Management
- Use `/clear` after completing each discrete task
- Run `git status` before commits, clean artifacts
- Start fresh sessions for major refactoring
- Quality over quantity - 10% relevant beats 100% noise

### Parallel Execution
- Make multiple Task tool calls in ONE message for parallel execution
- Use for: batch operations, independent tasks, multi-domain reviews
- Benefits: Faster completion, efficient resource usage

## Maintenance

### Zero Maintenance Areas (Automated)
- **Agent lists** - Dynamic discovery via hook
- **Skill lists** - Dynamic discovery via hook
- **Roster updates** - Automatic when files added/removed

### Periodic Tasks
- **Monthly:** Archive old todos (30+ days)
  ```bash
  find ~/.claude/todos -name "*.json" -mtime +30 -exec mv {} ~/.claude/todos/archive/ \;
  ```
- **As needed:** Update CLAUDE.md patterns based on learnings
- **Quarterly:** Audit permissions and review enabled plugins

### When Things Change
- **New agent/skill:** Just create the file - auto-discovered
- **Remove agent/skill:** Just delete the file - auto-removed
- **Update agent/skill:** Edit the file - changes immediate
- **Hook changes:** Edit discover-agents.sh, changes on next prompt

## Philosophy

This configuration embraces several key philosophies:

### 1. Dynamic Discovery
Never maintain manual lists of components. Let the system discover what exists at runtime. This ensures:
- Zero synchronization issues
- Always accurate information
- No stale documentation
- Effortless scalability

### 2. Conceptual Guidance
CLAUDE.md provides patterns and principles, not inventories. It answers:
- *When* to use agents vs skills vs commands
- *How* to parallelize work
- *What* patterns lead to better outcomes

Not:
- Which specific agents exist (hook provides this)
- What each agent does (agent descriptions provide this)

### 3. Progressive Disclosure
Load information only when needed:
- Hook output provides basic roster
- Agent descriptions provide detail when selected
- Supporting docs loaded only when referenced
- Context stays lean and focused

### 4. Convention Over Configuration
Standard patterns emerge naturally:
- Agents in `agents/` directory
- Skills in `skills/*/SKILL.md` structure
- Hooks in `hooks/` directory
- Documentation in `docs/` directory

No complex configuration files defining where things live.

### 5. Global by Default
This configuration applies to all projects, ensuring:
- Consistent behavior across work
- Accumulated knowledge benefits all projects
- Single source of truth for personal preferences
- Project-specific overrides only when truly needed

## Troubleshooting

### Hook Not Running
- Check `settings.json` has UserPromptSubmit hook configured
- Verify timeout is 60000ms (not 60ms)
- Ensure discover-agents.sh is executable: `chmod +x ~/.claude/hooks/discover-agents.sh`

### Agent Not Discovered
- Verify file is in `~/.claude/agents/` or `./.claude/agents/`
- Check file has `.md` extension
- Ensure file has valid YAML frontmatter with `name:` field
- Run hook manually to test: `bash ~/.claude/hooks/discover-agents.sh`

### Skill Not Discovered
- Verify directory structure: `~/.claude/skills/skill-name/SKILL.md`
- Check SKILL.md has valid YAML frontmatter
- Ensure `name:` field matches directory name
- Run hook manually to test: `bash ~/.claude/hooks/discover-agents.sh`

### Permission Issues
- Check `settings.local.json` for allow/deny/ask rules
- Remember: deny rules are exact matches or patterns
- Bash rules use prefix matching (not regex)
- Read rules affect WebFetch and direct file access

## Resources

### Official Documentation
- Claude Code Docs: https://code.claude.com/docs/
- Agent Documentation: https://code.claude.com/docs/en/sub-agents.md
- Skills Documentation: https://code.claude.com/docs/en/skills.md
- Hooks Reference: https://code.claude.com/docs/en/hooks.md

### Community Resources
- Claude Code Marketplace: https://claudecodemarketplace.com/
- Community Plugins: https://github.com/severity1/claude-code-marketplace
- Additional Plugins: https://github.com/jeremylongshore/claude-code-plugins-plus

### This Configuration
- Global instructions: `~/.claude/CLAUDE.md`
- Hook implementation: `~/.claude/hooks/discover-agents.sh`
- Settings: `~/.claude/settings.json`
- Permissions: `~/.claude/settings.local.json`

---

**Last Updated:** Configuration implements dynamic discovery architecture with zero-maintenance agent/skill rosters
**Maintained By:** Bartosz Glowacki
**Philosophy:** Automate discovery, document patterns, maintain simplicity
