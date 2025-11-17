# Progressive Disclosure in Skills

Progressive disclosure is a design pattern where you reveal information gradually, showing only what's needed when it's needed. This keeps skills focused and prevents information overload.

## Core Principle

**Show the minimum necessary information first, then provide paths to deeper details.**

Instead of:
```markdown
# Instructions
[10,000 words of every possible detail]
```

Use:
```markdown
# Instructions
[Core workflow in 500 words]

For advanced configuration, see [advanced-config.md](advanced-config.md)
For troubleshooting, see [troubleshooting.md](troubleshooting.md)
```

## Benefits

1. **Faster Loading**: Main SKILL.md stays under 5k tokens
2. **Better Focus**: Users see relevant info without distraction
3. **Easier Maintenance**: Update specific files without touching main instructions
4. **Scalable Complexity**: Support both beginners and experts

## Content Organization Strategy

### Level 1: SKILL.md (Essential)
**What to include:**
- YAML frontmatter (name, description, allowed-tools)
- Core workflow (numbered steps)
- 2-4 key examples
- Prerequisites

**What to exclude:**
- Detailed API references
- Comprehensive troubleshooting guides
- Edge case handling
- Advanced configuration options

**Token budget**: 3k-5k tokens

### Level 2: Supporting Files (Details)
**Common supporting files:**
- `api-reference.md`: Detailed API documentation
- `troubleshooting.md`: Common errors and solutions
- `advanced-config.md`: Advanced configuration options
- `examples/`: Directory of additional examples
- `templates/`: Code or config templates

**Token budget per file**: 2k-4k tokens

### Level 3: Deep Reference (Optional)
**For very complex skills:**
- `reference/`: Comprehensive reference materials
- `guides/`: Step-by-step tutorials for specific scenarios
- `glossary.md`: Domain-specific terminology

## Splitting Strategies

### Strategy 1: By Depth
Split main content from advanced content:

```
SKILL.md                    # Basic workflow
advanced-usage.md           # Power user features
internals.md                # How it works under the hood
```

**Example**: Database migration skill
- SKILL.md: Create migration, apply, rollback
- advanced-usage.md: Data migrations, custom SQL, squashing
- internals.md: Migration system architecture

### Strategy 2: By Topic
Split into topical modules:

```
SKILL.md                    # Overview + workflow
authentication.md           # Auth-specific details
authorization.md            # Authz-specific details
deployment.md               # Deployment considerations
```

**Example**: API development skill
- SKILL.md: Create endpoint, add validation, test
- authentication.md: JWT, OAuth, API keys
- authorization.md: Permissions, RBAC, policies
- deployment.md: Rate limiting, caching, monitoring

### Strategy 3: By Phase
Split along workflow phases:

```
SKILL.md                    # Overview + all phases briefly
1-planning.md               # Planning phase details
2-implementation.md         # Implementation phase details
3-testing.md                # Testing phase details
4-deployment.md             # Deployment phase details
```

**Example**: Feature development skill
- SKILL.md: High-level workflow
- 1-planning.md: Requirements analysis, design patterns
- 2-implementation.md: Coding standards, patterns
- 3-testing.md: Test strategies, coverage
- 4-deployment.md: Release checklist

### Strategy 4: By Scenario
Split into common scenarios:

```
SKILL.md                    # Basic scenario
scenario-large-dataset.md   # Handling large datasets
scenario-realtime.md        # Real-time requirements
scenario-distributed.md     # Distributed systems
```

**Example**: Data processing skill
- SKILL.md: Standard batch processing
- scenario-large-dataset.md: Streaming, partitioning
- scenario-realtime.md: Event-driven, low-latency
- scenario-distributed.md: Parallel processing, coordination

## Referencing Supporting Files

### Inline References
Point to supporting files contextually:

```markdown
## Step 3: Configure Authentication
Set up basic authentication using JWT tokens.

For advanced authentication methods (OAuth, SAML), see [authentication.md](authentication.md)
```

### End-of-Section References
Provide pointers at natural break points:

```markdown
## Workflow
1. **Plan**: Define requirements
2. **Implement**: Write code
3. **Test**: Verify functionality
4. **Deploy**: Release to production

**Additional Resources:**
- [Testing strategies](testing-strategies.md) for comprehensive test approaches
- [Deployment checklist](deployment-checklist.md) for production releases
- [Troubleshooting guide](troubleshooting.md) if issues arise
```

### Dedicated Reference Section
Add a reference section at the end:

```markdown
# Supporting Documentation

| Topic | File | Description |
|-------|------|-------------|
| API Reference | [api-reference.md](api-reference.md) | Complete API documentation |
| Configuration | [configuration.md](configuration.md) | All config options explained |
| Troubleshooting | [troubleshooting.md](troubleshooting.md) | Common issues and solutions |
| Examples | [examples/](examples/) | Additional code examples |
```

## File Naming Conventions

**Good names** (descriptive, scannable):
- `authentication-methods.md`
- `error-handling-guide.md`
- `deployment-checklist.md`
- `api-reference.md`

**Bad names** (ambiguous, unclear):
- `stuff.md`
- `notes.md`
- `misc.md`
- `details.md`

**Naming patterns:**
- Use lowercase with hyphens
- Be specific: `django-admin-setup.md` not `admin.md`
- Indicate content type: `-guide`, `-reference`, `-checklist`
- Use domain terms: `kubernetes-manifests.md` not `k8s.md`

## Content Density Guidelines

### SKILL.md Density
**Target**: 60-80% actionable content, 20-40% explanatory

```markdown
✅ GOOD (actionable):
1. **Create migration**: Run `python manage.py makemigrations`
2. **Review changes**: Check the generated migration file
3. **Apply migration**: Run `python manage.py migrate`

❌ BAD (too explanatory):
1. **Create migration**: Django's migration system is a powerful tool that
   allows you to manage database schema changes over time. When you modify
   your models, you need to create migrations which are Python files that
   describe the changes. To do this, run `python manage.py makemigrations`
   which will analyze your model changes and generate the appropriate
   migration code...
```

Move explanatory content to supporting files:
```markdown
For an in-depth explanation of Django migrations, see [migrations-guide.md](migrations-guide.md)
```

### Supporting File Density
**Target**: Can be more detailed, but stay focused

**Structure for supporting files:**
1. Quick summary at top (2-3 sentences)
2. Detailed content organized by subtopics
3. Examples showing usage
4. Related references at bottom

```markdown
# Authentication Methods

Quick overview: This guide covers JWT, OAuth, and API key authentication methods.

## JWT Authentication
[Detailed explanation]

## OAuth 2.0
[Detailed explanation]

## API Keys
[Detailed explanation]

## Related Documentation
- [Authorization guide](authorization.md)
- [Security best practices](security.md)
```

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Single Massive File
**Problem**: Everything in SKILL.md
**Impact**: Slow loading, hard to maintain, overwhelming

**Solution**: Split into focused modules

### ❌ Anti-Pattern 2: Over-Fragmentation
**Problem**: 50+ tiny files, each with 100 words
**Impact**: Constant navigation, broken flow, overhead

**Solution**: Group related content, aim for 2-4k tokens per file

### ❌ Anti-Pattern 3: Circular References
**Problem**: File A references File B, File B references File A
**Impact**: Confusing navigation, unclear primary source

**Solution**: Create clear hierarchy, reference down not across

### ❌ Anti-Pattern 4: Dead-End References
**Problem**: References to files that don't exist
**Impact**: Broken workflow, user frustration

**Solution**: Test all references, create files before referencing

### ❌ Anti-Pattern 5: Duplicate Content
**Problem**: Same info in multiple files
**Impact**: Maintenance burden, version drift, confusion

**Solution**: Single source of truth, cross-reference don't duplicate

## Testing Progressive Disclosure

### Checklist for Validation

**Information Architecture:**
- [ ] SKILL.md under 5k tokens
- [ ] Core workflow understandable without reading supporting files
- [ ] Supporting files are logically organized
- [ ] No circular references
- [ ] All file references work (no 404s)

**User Flow:**
- [ ] Beginner can complete basic task using only SKILL.md
- [ ] Advanced user can find detailed info via clear references
- [ ] Supporting files have clear purpose and scope
- [ ] Navigation between files is intuitive

**Content Quality:**
- [ ] No duplicate content across files
- [ ] Each file has single, clear purpose
- [ ] File names are descriptive and scannable
- [ ] References add value (not just placeholders)

## Examples of Good Progressive Disclosure

### Example 1: Testing Skill
```
testing-skill/
├── SKILL.md                    # Overview, basic workflow (4k tokens)
├── pytest-patterns.md          # Common pytest patterns (3k tokens)
├── mocking-strategies.md       # When and how to mock (2k tokens)
├── coverage-guide.md           # Coverage targets and tools (2k tokens)
└── examples/
    ├── unit-test-example.py    # Sample unit test
    ├── integration-test.py     # Sample integration test
    └── async-test-example.py   # Sample async test
```

**SKILL.md structure:**
```markdown
---
name: Pytest Test Generator
description: Generates comprehensive pytest tests...
---

# Instructions

## Workflow
1. **Analyze Code**: [basic description]
2. **Generate Tests**: [basic description]
3. **Verify Coverage**: [basic description]

For detailed pytest patterns, see [pytest-patterns.md](pytest-patterns.md)
For mocking strategies, see [mocking-strategies.md](mocking-strategies.md)

# Examples
[2-3 basic examples]

# Additional Resources
- [pytest-patterns.md](pytest-patterns.md): Advanced patterns
- [coverage-guide.md](coverage-guide.md): Coverage best practices
- [examples/](examples/): Sample test files
```

### Example 2: API Development Skill
```
api-development/
├── SKILL.md                    # Core workflow (4.5k tokens)
├── authentication.md           # Auth methods (3k tokens)
├── validation.md               # Input validation (2k tokens)
├── error-handling.md           # Error responses (2k tokens)
├── openapi-schema.md           # Schema generation (3k tokens)
└── deployment-considerations.md # Prod deployment (2k tokens)
```

**SKILL.md structure:**
```markdown
## Step 3: Add Authentication
Implement JWT authentication for the endpoint.

For alternative authentication methods (OAuth, API keys), see [authentication.md](authentication.md)

## Step 4: Validate Input
Add serializer validation.

For advanced validation patterns (custom validators, conditional validation), see [validation.md](validation.md)
```

---

## Key Takeaways

1. **Keep SKILL.md focused**: 3k-5k tokens, core workflow only
2. **Split by logical boundaries**: Depth, topic, phase, or scenario
3. **Reference contextually**: Point to supporting files where relevant
4. **Test navigation**: Ensure users can find what they need
5. **Avoid anti-patterns**: No massive files, over-fragmentation, or circular refs
6. **One source of truth**: Don't duplicate content across files
