# Agent Analysis Guidelines

This guide provides detailed criteria for analyzing agents for redundancy, overlap, and optimization opportunities.

## Agent Redundancy Assessment Framework

### 1. Overlap Percentage Calculation

Calculate overlap based on these dimensions:

**Purpose Overlap (40% weight)**
- Do they solve the same problem?
- Do they address the same domain/expertise?
- Is the end goal identical?
- Do they target the same use cases?

**Trigger Overlap (30% weight)**
- Do they activate on the same conditions?
- Are delegation triggers similar or identical?
- Would the same scenario invoke both?
- Is proactive behavior overlapping?

**Tool/Capability Overlap (30% weight)**
- Do they use the same tools?
- Are their capabilities similar?
- Do they perform the same actions?
- Is one a subset of the other?

**Formula:**
```
Total Overlap = (Purpose × 0.4) + (Trigger × 0.3) + (Tools/Capability × 0.3)
```

**Thresholds:**
- **< 30%**: No redundancy - Keep both
- **30-50%**: Low overlap - Likely complementary, keep both
- **50-70%**: Moderate overlap - Review for consolidation opportunity
- **> 70%**: High redundancy - Strongly consider consolidation

### 2. Agent Types and Specialization

Understanding agent types helps identify natural boundaries:

**Analysis Agents** (Read-only)
- Tools: Read, Grep, Glob
- DisallowedTools: Write, Edit, Bash
- Purpose: Code review, security audit, complexity analysis
- Examples: code-reviewer, security-auditor, architect-reviewer

**Implementation Agents** (Full access)
- Tools: Read, Write, Edit, Bash, Grep, Glob
- Purpose: Feature development, refactoring, code generation
- Examples: backend-developer, django-developer, python-pro

**Testing Agents**
- Tools: Read, Write, Bash, Grep, Glob
- Purpose: Test generation, execution, coverage validation
- Examples: test-automator, qa-expert, pytest-generator

**Documentation Agents**
- Tools: Read, Write, WebFetch, Grep, Glob
- Purpose: Documentation generation, API schemas, technical writing
- Examples: documentation-engineer, api-designer

**Infrastructure Agents**
- Tools: Read, Write, Edit, Bash, Grep, Glob
- Purpose: Deployment, configuration, DevOps tasks
- Examples: kubernetes-specialist, postgres-pro, database-optimizer

**Research Agents**
- Tools: Read, Grep, Glob, WebFetch, WebSearch
- DisallowedTools: Write, Edit, Bash
- Purpose: Information gathering, trend analysis, best practices
- Examples: research-analyst, trend-analyst

**Orchestration Agents**
- Tools: Task, Read, Grep, Glob (+ others as needed)
- Purpose: Coordinating multiple agents, complex workflows
- Examples: workflow-orchestrator, task-distributor, meta-orchestrator

### 3. Redundancy Patterns

**Pattern 1: Domain Overlap**
Two agents serving the same domain with similar capabilities.

**Example:**
- Agent A: `django-developer` - Django development expert
- Agent B: `backend-developer` - Backend development including Django
- Overlap Assessment:
  - Purpose: 70% (both do Django development)
  - Triggers: 60% (both trigger on Django code)
  - Tools: 90% (same tool set)
  - Total: 73% → High redundancy

**Decision**:
- If `django-developer` is more specialized → Keep both, `backend-developer` delegates Django to `django-developer`
- If capabilities identical → Consolidate into one

**Pattern 2: Scope Subsumption**
One agent is a strict subset of another.

**Example:**
- Agent A: `api-designer` - Designs APIs only
- Agent B: `backend-developer` - Full backend including API design
- Overlap: 40% (API design is subset of backend work)

**Decision**: Keep both - clear specialization boundary

**Pattern 3: Capability Duplication**
Different domains but overlapping capabilities.

**Example:**
- Agent A: `code-reviewer` - Reviews all code
- Agent B: `security-auditor` - Reviews code for security
- Overlap: 50% (security is one aspect of code review)

**Decision**: Keep both - `code-reviewer` focuses on quality, `security-auditor` deep-dives security

**Pattern 4: Temporal Evolution**
Older agent superseded by newer, better one.

**Example:**
- Agent A: `test-generator` (created 6 months ago)
- Agent B: `test-automator` (created recently, more comprehensive)
- Overlap: 85%

**Decision**: Deprecate older if newer is strictly better, or clarify specializations

### 4. Decision Matrix for Agent Redundancy

| Overlap % | Domain Similarity | Tool Similarity | Recommendation |
|-----------|------------------|-----------------|----------------|
| > 80% | Same | Same | **Consolidate** - Clear redundancy |
| > 70% | Same | Different | **Review** - May have different approaches |
| 50-70% | Same | Same | **Clarify** - Define specialization boundaries |
| 50-70% | Different | Same | **Keep** - Different domains using same tools |
| < 50% | Same | Different | **Keep** - Different capabilities in same domain |
| < 50% | Different | Any | **Keep** - Low overlap |

### 5. Complementary vs Redundant Agents

**Complementary (Keep Both):**
- ✅ General agent + Specialized expert (backend-developer + django-developer)
- ✅ Implementation agent + Review agent (feature-dev + code-reviewer)
- ✅ Different phases (test-generator + test-runner)
- ✅ Different scopes (code-reviewer + security-auditor)
- ✅ Orchestrator + Specialist (workflow-orchestrator + kubernetes-specialist)

**Redundant (Consider Consolidation):**
- ❌ Two agents with identical domain and tools
- ❌ Newer agent fully supersedes older agent
- ❌ One agent is unused/deprecated but not removed
- ❌ "Light" and "Pro" versions of same thing without clear boundary

### 6. Global vs Project Agents

Most agents should be global (`~/.claude/agents/`), but project agents (`.claude/agents/`) make sense for:

**Project Agents Justified:**
- Highly project-specific domain knowledge
- Custom workflows unique to this project
- Integration with project-specific tools/services
- Team-specific standards not applicable elsewhere

**Should Be Global:**
- Framework expertise (Django, React, etc.)
- Language expertise (Python, TypeScript, etc.)
- General patterns (testing, documentation, security)
- Reusable across projects

## Analysis Workflow

### Phase 1: Discovery

1. **List all agents:**
   ```bash
   # Global agents
   ls ~/.claude/agents/

   # Project agents (if any)
   ls .claude/agents/
   ```

2. **Read frontmatter for each:**
   ```bash
   for agent in ~/.claude/agents/*.md; do
     echo "=== $(basename $agent) ==="
     head -20 "$agent" | grep -A 10 "^---"
   done
   ```

3. **Catalog by domain:**
   - Group agents by primary domain (Django, testing, documentation, etc.)
   - Note tool sets for each
   - Identify proactive vs on-demand agents

### Phase 2: Comparison Within Domains

For each domain group:

1. **Compare purposes:**
   - List primary responsibility for each
   - Identify overlapping concerns
   - Note unique capabilities

2. **Compare triggers:**
   - When does each activate?
   - Are triggers overlapping or distinct?
   - Is proactive behavior redundant?

3. **Compare tool sets:**
   - Identical tools suggest similar capabilities
   - Different tools suggest different approaches
   - Tool restrictions indicate different scopes

4. **Calculate overlap percentage:**
   Use formula from Section 1

### Phase 3: Cross-Domain Analysis

Check for capabilities that span domains:

**Common Cross-Domain Overlaps:**
- Code review capabilities in multiple specialized agents
- Testing capabilities in domain-specific agents
- Documentation generation across multiple agents

**Questions to Ask:**
1. Should domain agent delegate to specialist?
2. Should specialist cover all domains?
3. Is overlap intentional (local context) or accidental?

### Phase 4: Recommendations

For each redundancy found:

**High Priority (>70% overlap):**
```markdown
## Redundancy: [Agent A] ↔ [Agent B]

**Overlap Analysis:**
- Purpose: [X]%
- Triggers: [Y]%
- Tools: [Z]%
- **Total: [N]%**

**Current State:**
- [Agent A]: [Description and unique capabilities]
- [Agent B]: [Description and unique capabilities]

**Recommendation:** [Consolidate|Deprecate|Specialize]

**Action Plan:**
1. [Specific step]
2. [Specific step]

**Migration Path:**
- Update references from [old] to [new]
- Document deprecation
- Remove deprecated agent
```

**Medium Priority (50-70% overlap):**
- Document relationship
- Clarify specialization boundaries
- Update descriptions to reduce ambiguity
- Consider delegation patterns

**Low Priority (30-50% overlap):**
- Note complementary relationship
- No action needed
- Monitor for drift

## Common Consolidation Strategies

### Strategy 1: Merge Capabilities

**When**: Two agents with nearly identical purpose and tools

**How**:
1. Create new agent combining best of both
2. Migrate unique capabilities
3. Test thoroughly
4. Update documentation
5. Deprecate both old agents

**Example:**
- `api-designer` + `api-documenter` → `api-specialist`

### Strategy 2: Establish Specialization Hierarchy

**When**: One agent is general, other is specialized

**How**:
1. Keep both agents
2. Update general agent to delegate to specialist for specialized tasks
3. Clarify scope in descriptions
4. Document delegation pattern

**Example:**
- `backend-developer` delegates Django-specific tasks to `django-developer`

### Strategy 3: Deprecate Older Agent

**When**: Newer agent strictly supersedes older one

**How**:
1. Verify newer agent covers all use cases
2. Mark older agent as deprecated in description
3. Update to redirect to new agent
4. After migration period, remove old agent

**Example:**
- `test-generator` (old) → `test-automator` (new, comprehensive)

### Strategy 4: Split Responsibilities

**When**: One agent does too much, overlapping with others

**How**:
1. Identify distinct responsibilities
2. Create focused agents for each
3. Remove overly-broad agent
4. Establish clear delegation

**Example:**
- `full-stack-developer` → `backend-developer` + `frontend-developer`

## Quality Checklist

After analysis:

- [ ] All high-overlap redundancies identified and addressed
- [ ] Complementary agents clearly documented
- [ ] Specialization boundaries defined
- [ ] Delegation patterns established
- [ ] Deprecated agents marked/removed
- [ ] Documentation updated
- [ ] No loss of capabilities
- [ ] All use cases still covered

## Maintenance Schedule

**Quarterly Review:**
- New agents added since last review?
- Have agents evolved to overlap?
- Unused agents to remove?
- Emerging patterns to capture?

**After Major Changes:**
- New framework/technology adopted
- Team practices changed
- Project architecture evolved
- Major agent capabilities added

**Continuous:**
- When creating new agents, check for overlaps first
- When agents feel redundant during use
- When users ask "which agent should I use?"
- When delegation seems unclear

## Examples

### Example 1: High Redundancy - Consolidate

**Agents:**
- `django-expert` - Django development specialist
- `django-developer` - Django development expert

**Analysis:**
- Purpose: 95% (essentially identical)
- Triggers: 90% (both trigger on Django code)
- Tools: 100% (identical tool sets)
- **Total: 95% overlap**

**Recommendation:** Consolidate into `django-developer`, deprecate `django-expert`

**Action:**
1. Compare capabilities, ensure nothing lost
2. Update `django-developer` with any unique features from `django-expert`
3. Mark `django-expert` as deprecated, point to `django-developer`
4. After 2 weeks, remove `django-expert`

### Example 2: Moderate Overlap - Clarify Specialization

**Agents:**
- `code-reviewer` - General code quality review
- `architect-reviewer` - Architecture and design review

**Analysis:**
- Purpose: 50% (code review vs architecture review)
- Triggers: 60% (both review code, different focus)
- Tools: 80% (mostly same, read-only)
- **Total: 63% overlap**

**Recommendation:** Keep both, clarify boundaries

**Action:**
1. Update `code-reviewer` description: "Focuses on code quality, S.O.L.I.D principles, not architecture"
2. Update `architect-reviewer` description: "Focuses on system design, not code-level quality"
3. Establish delegation: `architect-reviewer` can call `code-reviewer` for code-level checks
4. Document complementary use: Architecture review first, then code review

### Example 3: Low Overlap - Keep Both

**Agents:**
- `security-auditor` - Security vulnerability review
- `performance-engineer` - Performance optimization

**Analysis:**
- Purpose: 20% (different concerns)
- Triggers: 30% (both review code, different aspects)
- Tools: 60% (read-only analysis, but different approaches)
- **Total: 37% overlap**

**Recommendation:** Keep both, complementary specialists

**Action:**
- Document that both may review same code for different concerns
- No changes needed
