---
name: Meta-Skill - Create and Manage Skills
description: |
  Teaches how to create, analyze, and maintain Claude Code Agent Skills with progressive disclosure patterns.
  Use this when:
    - Creating new skills specifically (for agent vs skill decision, use @meta-orchestrator)
    - Analyzing skills for redundancy or overlap
    - Standardizing existing skill frontmatter
    - Reviewing skill organization or configuration
    - Checking relationships between skills and agents
    - User asks to "verify skills", "check skills", "analyze skill redundancy", or "standardize skills"
    - Working with .claude/skills/ directory

  Note: For unified agent + skill management or agent vs skill decisions, use @meta-orchestrator instead.
---

# Instructions

## Relationship with Meta-Orchestrator

This meta-skill focuses specifically on **creating and managing skills**. For broader operations:

**Use meta-orchestrator** (`@meta-orchestrator`) for:
- Deciding whether to create an agent or skill
- Creating agents
- Analyzing both agents and skills together
- Cross-ecosystem redundancy checks

**Use this meta-skill** for:
- Detailed skill creation guidance
- Skill-specific analysis and maintenance
- Skill templates and patterns
- Progressive disclosure in skills

---

## Prerequisites
- Understanding of the task or workflow to be captured
- Knowledge of when the skill should be triggered
- Identification of required tools and resources

## Workflow

### Step 1: Define the Skill Purpose
Ask the user to clarify:
- **What task** does this skill accomplish?
- **When should it be used?** (trigger conditions)
- **What expertise** should it capture?
- **What resources** does it need? (tools, files, APIs)

### Step 2: Choose Installation Location
Determine where to create the skill:
- **Team/Project skills**: `.claude/skills/<skill-name>/` (checked into git, shared with team)
- **Personal skills**: `~/.claude/skills/<skill-name>/` (global, user-specific)

Create the directory structure:
```bash
mkdir -p <chosen-path>/<skill-name>
```

### Step 3: Create SKILL.md with Frontmatter
Every skill requires a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: Skill Display Name
description: |
  What this skill does and when to use it.
  Use this when: [specific trigger conditions]
allowed-tools: [Read, Write, Bash]  # Optional: restrict available tools
---
```

**Frontmatter Guidelines:**
- `name`: Max 64 characters, descriptive title
- `description`: Max 1024 characters, include both functionality AND trigger conditions
- `allowed-tools`: Optional list to restrict tool usage (useful for safety)

### Step 4: Write Clear Instructions
Organize the main content into sections:

```markdown
# Instructions

## Prerequisites
- List required knowledge or setup
- Dependencies or external tools needed

## Workflow
1. **Step One**: Clear, actionable description
2. **Step Two**: What to do and why
3. **Step Three**: Expected outcomes

## Supporting Details
- Best practices
- Common pitfalls to avoid
- Additional context
```

**Best Practices:**
- Use numbered steps for workflows
- Keep instructions focused (under 5k tokens)
- Use bold for emphasis: **important terms**
- Write actionable language: "Create X", "Run Y", "Verify Z"

### Step 5: Add Concrete Examples
Include 2-4 examples showing different use cases:

```markdown
# Examples

## Example 1: Basic Use Case
**User Request**: "Add user authentication"

**Actions Taken**:
1. Created User model with Django auth
2. Implemented JWT token generation
3. Added login/logout endpoints

**Expected Outcome**: Working authentication system with tests

## Example 2: Advanced Scenario
[Additional examples showing edge cases or variations]
```

**Example Guidelines:**
- Show realistic user requests
- Demonstrate step-by-step execution
- Include expected outcomes
- Cover different scenarios (basic, advanced, edge cases)

### Step 6: Create Supporting Files (Optional)
Split complex content across multiple files:

```markdown
For detailed configuration options, see [configuration.md](configuration.md)
```

**Supporting File Best Practices:**
- Use relative paths for references
- One topic per file (e.g., `api-reference.md`, `troubleshooting.md`)
- Keep file names descriptive and lowercase with hyphens
- Total skill content should stay under 10k tokens

### Step 7: Test the Skill
Validate the skill works correctly:

1. **Check YAML validity**: Ensure frontmatter parses correctly
2. **Test trigger conditions**: Verify skill activates when expected
3. **Run through examples**: Execute the examples to confirm accuracy
4. **Iterate on clarity**: Refine instructions based on test results

**Testing Checklist:**
- [ ] YAML frontmatter is valid
- [ ] Description includes clear trigger conditions
- [ ] Instructions are actionable and clear
- [ ] Examples work as documented
- [ ] Supporting files are accessible
- [ ] Skill loads without errors

### Step 8: Commit and Share (for team skills)
If creating a team skill in `.claude/skills/`:

```bash
git add .claude/skills/<skill-name>
git commit -m "Add <skill-name> skill"
git push
```

Team members will automatically receive the skill on next pull.

## Key Principles

**Progressive Disclosure**: Load only what's needed when needed
- Keep main SKILL.md focused and concise
- Split detailed reference material into supporting files
- Reference supporting content only when relevant

**Single Responsibility**: One skill = one capability
- Don't combine multiple unrelated tasks
- Create separate skills for distinct workflows
- Keep skills focused and maintainable

**Clear Triggers**: Make activation conditions explicit
- Describe WHEN to use the skill in the description
- Use specific trigger phrases users might say
- Avoid ambiguous or overlapping triggers

**Tool Restrictions**: Use `allowed-tools` for safety
- Restrict destructive operations (e.g., only Read/Grep for analysis skills)
- Grant full access for implementation skills
- Document why tools are restricted

## Skill Analysis & Maintenance

Beyond creating new skills, this meta-skill also guides you in analyzing and maintaining existing skills.

### Analyzing Skills for Redundancy

When user requests to "verify skills", "check for redundancy", or "analyze skill configuration":

**Step 1: Inventory Skills**
- List all global skills (`~/.claude/skills/`)
- List all project skills (`.claude/skills/`)
- List all global agents (`~/.claude/agents/`)
- List all project agents (`.claude/agents/`) if present

**Step 2: Identify Overlaps**
- Compare skill purposes and trigger conditions
- Check for overlaps between skills and agents
- Identify skills that cover the same domain
- Look for redundant validation checklists

**Step 3: Assess Redundancy Type**
- **Complementary**: Different purposes (e.g., implementation skill + validation skill) → Keep both
- **Agent overlap**: Skill duplicates agent capability → Evaluate if agent is sufficient
- **Duplicate skills**: Same purpose and triggers → Consolidate

**Step 4: Provide Recommendations**
- Remove true duplicates
- Consolidate skills with >70% overlap
- Keep complementary skills with clear role separation
- Document relationships between related skills/agents

For detailed analysis guidelines, see [skill-analysis.md](skill-analysis.md)

### Standardizing Skill Frontmatter

When skills lack proper YAML frontmatter or need standardization:

**Step 1: Identify Skills Without Frontmatter**
- Check each skill file for YAML frontmatter
- Note skills with missing or incomplete frontmatter

**Step 2: Add Frontmatter Following Template**
```yaml
---
name: Descriptive Skill Name
description: |
  Clear description of what this skill does.
  Use this when: [specific trigger conditions that activate this skill]
allowed-tools: [Read, Grep, Bash]  # Restrict if needed
---
```

**Step 3: Ensure Trigger Clarity**
- Every description must include "Use this when:" section
- Triggers should be specific and unambiguous
- Include user phrases that should activate skill

**Step 4: Set Appropriate Tool Restrictions**
- Validation skills: `[Read, Grep, Bash]` (read-only)
- Implementation skills: Full access or specific tools needed
- Document reasoning for restrictions

### Reviewing Skill Organization

When evaluating overall skill structure:

**Check for:**
- Clear separation between global (reusable) and project (specific) skills
- Proper directory structure for multi-file skills
- Up-to-date README documentation
- Supporting files referenced correctly
- No orphaned or outdated skills

**Optimization Opportunities:**
- Split large skills with multiple concerns
- Combine tiny skills that are always used together
- Move project-specific global skills to project directory
- Move reusable project skills to global directory

# Examples

## Example 1: Creating a Database Migration Skill

**User Request**: "Create a skill for generating Django migrations safely"

**Actions Taken**:
1. Created `.claude/skills/django-migrations/SKILL.md`
2. Added frontmatter with trigger: "when user needs to create or apply Django migrations"
3. Wrote workflow: check changes → generate migration → review → apply → verify
4. Added examples: initial migration, schema changes, data migrations
5. Restricted tools to: `[Read, Bash, Grep]` (no Write to prevent accidental changes)
6. Created supporting file: `migration-checklist.md` with common issues

**Expected Outcome**: Skill that safely guides through migration creation with guardrails

## Example 2: Creating an API Documentation Skill

**User Request**: "I want a skill that updates OpenAPI schemas automatically"

**Actions Taken**:
1. Created `~/.claude/skills/openapi-updater/SKILL.md` (personal skill)
2. Description includes: "Use when: new endpoints added, existing endpoints modified, or user requests API docs update"
3. Workflow: detect changes → generate schema → validate → update static files → verify
4. Added 3 examples: new endpoint, modified endpoint, delete endpoint
5. Created supporting files:
   - `schema-validation.md`: How to validate OpenAPI 3.0 schemas
   - `common-errors.md`: Troubleshooting schema generation issues
6. Tested with actual endpoint changes

**Expected Outcome**: Automated API documentation updates with validation

## Example 3: Creating a Security Review Skill

**User Request**: "Build a skill that checks for common security vulnerabilities"

**Actions Taken**:
1. Created `.claude/skills/security-review/SKILL.md` (team skill for consistency)
2. Trigger: "when code is written, before commits, or user requests security check"
3. Workflow: scan for OWASP Top 10 → check auth/authz → review secrets → validate input sanitization
4. Added 4 examples: SQL injection check, XSS prevention, secret detection, CSRF validation
5. Restricted tools to: `[Read, Grep, Bash]` (read-only for safety)
6. Created supporting files:
   - `owasp-checklist.md`: OWASP Top 10 reference
   - `django-security.md`: Django-specific security patterns
   - `remediation-guide.md`: How to fix common issues

**Expected Outcome**: Consistent security review process across the team

## Example 4: Creating a Test Generation Skill

**User Request**: "Make a skill that generates comprehensive pytest tests"

**Actions Taken**:
1. Created `.claude/skills/pytest-generator/SKILL.md`
2. Description: "Use when: new features implemented, existing code needs test coverage, or user requests test generation"
3. Workflow: analyze code → identify test scenarios → generate fixtures → write tests → verify coverage
4. Added examples: unit tests, integration tests, async tests, parametrized tests
5. Full tool access needed for writing test files
6. Created supporting files:
   - `pytest-patterns.md`: Common pytest patterns and fixtures
   - `coverage-guide.md`: Achieving high coverage without over-testing
   - `mocking-strategies.md`: When and how to use mocks

**Expected Outcome**: High-quality pytest tests following project conventions

# Supporting Content

For advanced skill creation patterns and templates, see:
- [skill-templates.md](skill-templates.md) - Ready-to-use skill templates
- [progressive-disclosure.md](progressive-disclosure.md) - Advanced content organization
- [tool-restrictions.md](tool-restrictions.md) - When and how to restrict tools

---

**Remember**: Good skills are focused, actionable, and have clear trigger conditions. Start simple, test thoroughly, and iterate based on usage.
