# Skill Analysis Guidelines

This guide provides detailed criteria for analyzing skills and agents for redundancy, overlap, and optimization opportunities.

## Redundancy Assessment Framework

### 1. Overlap Percentage Calculation

Calculate overlap based on these dimensions:

**Purpose Overlap (40% weight)**
- Do they solve the same problem?
- Do they address the same use cases?
- Is the end goal identical?

**Trigger Overlap (30% weight)**
- Do they activate on the same user requests?
- Are the trigger conditions similar or identical?
- Would the same scenario invoke both?

**Content Overlap (30% weight)**
- Do they provide similar guidance/checklists?
- Is the technical content duplicated?
- Are the examples and patterns the same?

**Formula:**
```
Total Overlap = (Purpose × 0.4) + (Trigger × 0.3) + (Content × 0.3)
```

**Thresholds:**
- **< 30%**: No redundancy - Keep both
- **30-50%**: Low overlap - Likely complementary, keep both
- **50-70%**: Moderate overlap - Review for consolidation opportunity
- **> 70%**: High redundancy - Strongly consider consolidation

### 2. Skill vs Agent Overlap

Special considerations when comparing skills to agents:

**Agent Characteristics:**
- Autonomous execution
- Can create and modify files
- Explores codebase independently
- Makes decisions based on analysis
- Proactive (triggers automatically)
- Broader scope and capabilities

**Skill Characteristics:**
- Reference guide/checklist
- Provides validation criteria
- Declarative (what to check, not how)
- Narrow, focused scope
- Context for other agents/Claude

**Decision Matrix:**

| Overlap % | Agent Capability | Skill Purpose | Recommendation |
|-----------|-----------------|---------------|----------------|
| > 70% | Comprehensive | Validation checklist | **Remove skill** - Agent covers it |
| > 70% | Comprehensive | Implementation guide | **Review** - May be redundant |
| 50-70% | Broad | Narrow/specific | **Keep both** - Complementary |
| 50-70% | Autonomous | Validation only | **Keep both** - Different roles |
| < 50% | Any | Any | **Keep both** - Low overlap |

**Key Questions:**
1. Can the agent proactively handle what the skill provides?
2. Is the skill just a subset of the agent's capabilities?
3. Does the skill provide project-specific context the agent lacks?
4. Would removing the skill lose valuable quick-reference material?

### 3. Complementary vs Redundant

**Complementary (Keep Both):**
- ✅ Implementation skill + Validation skill (different phases)
- ✅ General agent + Specific project checklist (different scopes)
- ✅ Creation skill + Review skill (different actions)
- ✅ Proactive agent + Reference checklist (different triggers)

**Redundant (Consider Consolidation):**
- ❌ Two skills with identical checklists
- ❌ Skill duplicates agent's proactive behavior
- ❌ Multiple skills for same narrow purpose
- ❌ Skill provides only a subset of agent capabilities

### 4. Global vs Project Skills

**Global Skills** (`~/.claude/skills/`):
- Reusable across projects
- Technology/framework-focused
- General best practices
- No project-specific references

**Project Skills** (`.claude/skills/`):
- Project-specific validation
- References project structure
- Uses project conventions
- Team standards and patterns

**Migration Triggers:**

**Move to Global if:**
- No project-specific references
- Applicable to other projects
- General framework/technology guidance
- Could benefit other teams

**Move to Project if:**
- References specific project structure
- Uses project naming conventions
- Enforces team-specific standards
- Contains project-specific examples

## Analysis Workflow

### Phase 1: Discovery

1. **List all skills and agents:**
   ```bash
   # Global skills
   ls ~/.claude/skills/

   # Project skills
   ls .claude/skills/

   # Global agents
   ls ~/.claude/agents/

   # Project agents (if any)
   ls .claude/agents/
   ```

2. **Read frontmatter for each:**
   - Name
   - Description
   - Trigger conditions
   - Allowed tools

3. **Scan content for each:**
   - Main purpose
   - Key sections
   - Examples provided
   - Supporting files

### Phase 2: Comparison

1. **Group by domain:**
   - Event sourcing skills/agents
   - API documentation skills/agents
   - Kubernetes skills/agents
   - Django skills/agents
   - Testing skills/agents
   - Security skills/agents

2. **Compare within groups:**
   - Calculate overlap percentages
   - Identify trigger conflicts
   - Check content duplication

3. **Document findings:**
   ```markdown
   ## Domain: API Documentation

   **Global Agent:** documentation-engineer
   - Purpose: Comprehensive API documentation
   - Triggers: Proactive on API changes
   - Capabilities: OpenAPI schema, tutorials, examples

   **Project Skill:** api-documentation-update.md
   - Purpose: OpenAPI schema update checklist
   - Triggers: Manual reference
   - Capabilities: Validation checklist

   **Overlap:** 80% (Purpose: 90%, Trigger: 70%, Content: 80%)

   **Recommendation:** Remove project skill - agent is comprehensive and proactive
   ```

### Phase 3: Recommendations

For each redundancy found:

1. **High Priority (>70% overlap):**
   - Immediate action recommended
   - Clear consolidation path
   - Document what is removed
   - Update references in README

2. **Medium Priority (50-70% overlap):**
   - Review with user/team
   - Consider consolidation
   - May clarify roles instead
   - Document relationship

3. **Low Priority (30-50% overlap):**
   - Document complementary nature
   - Clarify different use cases
   - Update descriptions to reduce ambiguity
   - No removal needed

### Phase 4: Implementation

1. **Before removing anything:**
   - Verify agent/remaining skill covers all use cases
   - Check for project-specific content that might be lost
   - Review with team/user if applicable
   - Document the change

2. **Consolidation options:**
   - **Remove entirely:** High redundancy, no unique value
   - **Merge content:** Combine unique sections into one
   - **Clarify roles:** Update descriptions to show complementary nature
   - **Split differently:** Reorganize based on different boundaries

3. **After changes:**
   - Update README documentation
   - Update references in other skills
   - Test that triggers still work
   - Verify coverage of all use cases

## Common Patterns

### Pattern 1: Agent Supersedes Skill

**Scenario:** Global agent added after project skill was created

**Example:**
- Project skill: `openapi-updater` (created 6 months ago)
- Global agent: `documentation-engineer` (added recently, proactive)
- Overlap: 85%

**Action:** Remove project skill, note in README that agent handles it

### Pattern 2: Complementary Implementation + Validation

**Scenario:** One creates, one validates

**Example:**
- Global skill: `create-event-sourced-aggregate` (step-by-step creation)
- Project skill: `event-sourcing-patterns` (validation checklist)
- Overlap: 40%

**Action:** Keep both, document complementary relationship

### Pattern 3: General Agent + Specific Checklist

**Scenario:** Broad agent + narrow project checklist

**Example:**
- Global agent: `kubernetes-specialist` (creates/modifies manifests)
- Project skill: `kubernetes-manifest-validation` (project-specific checks)
- Overlap: 45%

**Action:** Keep both, skill provides project context for agent

### Pattern 4: Duplicate Skills

**Scenario:** Same skill in global and project

**Example:**
- Global skill: `django-migration-review`
- Project skill: `django-migration-review` (identical copy)
- Overlap: 100%

**Action:** Remove project copy, use global skill

## Quality Checklist

After analysis, verify:

- [ ] All high-overlap redundancies identified
- [ ] Agent vs skill relationships documented
- [ ] Complementary skills clearly explained
- [ ] README updated with changes
- [ ] No loss of unique content
- [ ] All use cases still covered
- [ ] Triggers are unambiguous
- [ ] Team/user consulted for project skills

## Maintenance Schedule

**Quarterly Review:**
- New skills/agents added?
- Updated skills/agents overlapping now?
- Outdated skills to remove?
- Skills that should become agents?

**After Major Changes:**
- New framework version adopted
- Team practices changed
- Project architecture evolved
- New global agents available

**Continuous:**
- When creating new skills, check for overlaps
- When skills feel redundant during use
- When users ask "which should I use?"
