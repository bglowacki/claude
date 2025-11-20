---
name: Event-Sourced Aggregate Patterns
description: Pattern catalog and validation guide for event-sourced aggregates using Python eventsourcing library with DDD patterns. Contains 4 aggregate patterns (simple, state transitions, collections, business rules) and anti-patterns reference. Use this when validating aggregate designs, reviewing event-sourcing implementations, or learning aggregate patterns. For implementation, use with @eventsourcing-expert agent.
allowed-tools: [Read, Grep, Glob, mcp__context7__resolve-library-id, mcp__context7__get-library-docs]
---

# Event-Sourced Aggregate Patterns & Validation

## Skill Purpose

This skill provides:
- **Pattern Catalog**: 4 proven aggregate design patterns with working examples
- **Anti-Patterns Reference**: Common pitfalls and how to avoid them
- **Validation Checklist**: Review criteria for aggregate implementations
- **Best Practices**: DDD principles and event sourcing guidelines

## Working with the eventsourcing-expert Agent

**This skill provides patterns and validation; use @eventsourcing-expert agent for implementation.**

**Typical Workflow:**
1. Review patterns in this skill to understand options
2. Invoke @eventsourcing-expert agent to create aggregate implementation
3. Use this skill's validation checklist to review the result
4. Use anti-patterns section to identify potential issues

**Division of Responsibilities:**
- **This Skill**: Reference guide, pattern examples, validation criteria (read-only)
- **eventsourcing-expert Agent**: Implementation, code generation, file creation (read-write)

# Instructions

## Prerequisites for Using This Skill
- Basic understanding of Domain-Driven Design (DDD) concepts
- Familiarity with event sourcing principles
- Access to Python eventsourcing library documentation (can be fetched via MCP tools)

## How to Use This Skill

### As a Pattern Reference
Browse the 4 aggregate patterns (below) to find the design that matches your use case:
1. **Simple Aggregate** - Single entity with minimal state
2. **State Transitions** - Lifecycle with explicit states
3. **Collections** - Managing child entities
4. **Business Rules** - Complex invariant protection

### As a Validation Tool
Use the validation checklist and anti-patterns sections to review aggregate implementations:
- Check against best practices
- Identify common pitfalls
- Verify event sourcing patterns
- Ensure DDD principles are followed

### Working with Official Documentation
Retrieve the latest eventsourcing library documentation:

```python
# Resolve library ID
mcp__context7__resolve-library-id(libraryName="eventsourcing")

# Fetch aggregate documentation
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/pyeventsourcing/eventsourcing",
    topic="aggregates",
    page=1
)
```

This ensures validation against current eventsourcing library best practices.

## Aggregate Design Considerations

### Defining Aggregate Boundaries
Key questions when defining aggregate boundaries:

**Responsibility Questions:**
- What invariants must the aggregate protect?
- What domain concepts does it encapsulate?
- What commands will it handle?
- What events will it emit?
- What state does it maintain?

**DDD Principles:**
- Keep aggregates small and focused
- One aggregate = one consistency boundary
- Aggregates protect business rules
- External references by ID only (no direct object refs)

### Domain Event Design
Events represent state changes in past tense:

**Event Naming Conventions:**
- Use past tense: `Created`, `Updated`, `Deleted`, `Activated`
- Be domain-specific: `GitHubInstallationCreated`, `WidgetRegistryEndpointActivated`
- Capture meaningful business events, not CRUD operations

**Event Structure Guidelines:**
- Immutable (use frozen dataclasses)
- Past-tense names
- Include all data needed for projections
- Type hints for all fields
- No business logic in events

### Aggregate Implementation Structure
Standard project structure for aggregates:

```
apps/registry/<bounded_context>/<aggregate_name>/
├── aggregate.py              # Aggregate implementation
├── commands.py               # Command handlers
├── tests/
│   └── test_<aggregate>_aggregate.py
```

**Key Implementation Patterns:**
- Inherit from `Aggregate`
- Define events as nested classes
- Use `@classmethod create()` for creation
- Use `trigger_event()` to emit events
- Implement `_apply()` for event handling
- Protect invariants in command methods before triggering events
- Raise domain exceptions for validation errors

### Validation Requirements
When reviewing aggregate implementations, verify:

**Structure:**
- ✅ Inherits from `eventsourcing.domain.Aggregate`
- ✅ Events defined as nested classes
- ✅ All events have type hints
- ✅ `_apply()` method handles all events

**Behavior:**
- ✅ Validation occurs BEFORE `trigger_event()`
- ✅ State changes only via events (no direct mutation)
- ✅ Events use past tense naming
- ✅ Invariants protected in command methods

**Testing:**
- ✅ Tests for creation
- ✅ Tests for updates
- ✅ Tests for validation failures
- ✅ Tests for event sourcing reconstruction

## Aggregate Design Patterns

### Pattern 1: Simple Aggregate
Single entity with minimal state:

```python
class WidgetRegistryEndpoint(Aggregate):
    def __init__(self, url: str, name: str, tenant_id: str, **kwargs):
        super().__init__(**kwargs)
        self.url = url
        self.name = name
        self.tenant_id = tenant_id
        self.is_active = True

    class Created(Aggregate.Created):
        url: str
        name: str
        tenant_id: str

    @classmethod
    def create(cls, url: str, name: str, tenant_id: str) -> "WidgetRegistryEndpoint":
        return cls._create(cls.Created, id=cls.create_id(), url=url, name=name, tenant_id=tenant_id)
```

### Pattern 2: Aggregate with State Transitions
Lifecycle with explicit states:

```python
from enum import Enum

class InstallationStatus(str, Enum):
    PENDING = "pending"
    ACTIVE = "active"
    SUSPENDED = "suspended"

class GitHubInstallation(Aggregate):
    def __init__(self, installation_id: int, account_login: str, **kwargs):
        super().__init__(**kwargs)
        self.installation_id = installation_id
        self.account_login = account_login
        self.status = InstallationStatus.PENDING

    class Activated(Aggregate.Event):
        pass

    def activate(self) -> None:
        if self.status != InstallationStatus.PENDING:
            raise ValueError(f"Cannot activate installation in {self.status} status")

        self.trigger_event(self.Activated)

    def _apply(self, event: Aggregate.Event) -> None:
        super()._apply(event)
        if isinstance(event, self.Activated):
            self.status = InstallationStatus.ACTIVE
```

### Pattern 3: Aggregate with Collections
Managing child entities:

```python
class GitHubInstallation(Aggregate):
    def __init__(self, installation_id: int, **kwargs):
        super().__init__(**kwargs)
        self.installation_id = installation_id
        self.repository_ids: set[int] = set()

    class RepositoryAdded(Aggregate.Event):
        repository_id: int
        repository_name: str

    def add_repository(self, repository_id: int, repository_name: str) -> None:
        if repository_id in self.repository_ids:
            raise ValueError(f"Repository {repository_id} already exists")

        self.trigger_event(
            self.RepositoryAdded,
            repository_id=repository_id,
            repository_name=repository_name
        )

    def _apply(self, event: Aggregate.Event) -> None:
        super()._apply(event)
        if isinstance(event, self.RepositoryAdded):
            self.repository_ids.add(event.repository_id)
```

### Pattern 4: Aggregate with Business Rules
Complex invariant protection:

```python
class WidgetRegistryEndpoint(Aggregate):
    MAX_ENDPOINTS_PER_TENANT = 10

    def __init__(self, url: str, tenant_id: str, **kwargs):
        super().__init__(**kwargs)
        self.url = url
        self.tenant_id = tenant_id

    @classmethod
    def create(cls, url: str, tenant_id: str, existing_count: int) -> "WidgetRegistryEndpoint":
        if existing_count >= cls.MAX_ENDPOINTS_PER_TENANT:
            raise ValueError(
                f"Tenant {tenant_id} has reached maximum endpoints limit ({cls.MAX_ENDPOINTS_PER_TENANT})"
            )

        if not url.startswith("https://"):
            raise ValueError("URL must use HTTPS")

        return cls._create(cls.Created, id=cls.create_id(), url=url, tenant_id=tenant_id)
```

## Anti-Patterns and Common Pitfalls

**This section is critical for validation - review aggregate code against these pitfalls.**

### Common Pitfalls Overview

| Pitfall | Symptom | Impact |
|---------|---------|--------|
| Forgetting `_apply()` | State not updated after events | Event sourcing reconstruction fails |
| Validation after event | Invalid state persisted | Data corruption, inconsistent state |
| Direct state mutation | Events not emitted | Audit trail lost, no event history |
| Logic in events | Business rules in event classes | Cannot change rules, violates CQRS |
| Cross-aggregate references | Direct object references | Tight coupling, boundary violations |
| Large aggregates | Too many responsibilities | Performance issues, complex testing |

### Pitfall 1: Forgetting to Call _apply()
❌ **Wrong:**
```python
def update_name(self, name: str) -> None:
    self.trigger_event(self.NameUpdated, name=name)
    # Missing _apply() call or implementation
```

✅ **Correct:**
```python
def update_name(self, name: str) -> None:
    self.trigger_event(self.NameUpdated, name=name)

def _apply(self, event: Aggregate.Event) -> None:
    super()._apply(event)
    if isinstance(event, self.NameUpdated):
        self.name = event.name
```

### Pitfall 2: Validation After Event
❌ **Wrong:**
```python
def update_name(self, name: str) -> None:
    self.trigger_event(self.NameUpdated, name=name)
    if not name:
        raise ValueError("Name required")  # Too late!
```

✅ **Correct:**
```python
def update_name(self, name: str) -> None:
    if not name:
        raise ValueError("Name required")
    self.trigger_event(self.NameUpdated, name=name)
```

### Pitfall 3: Mutating State Directly
❌ **Wrong:**
```python
def update_name(self, name: str) -> None:
    self.name = name  # Direct mutation, no event!
```

✅ **Correct:**
```python
def update_name(self, name: str) -> None:
    self.trigger_event(self.NameUpdated, name=name)
```

## Best Practices Checklist

**Use this checklist when validating aggregate implementations:**

### Design Best Practices
✅ **Keep aggregates small** - Focus on single responsibility
✅ **One consistency boundary** - One aggregate per transactional boundary
✅ **Reference by ID only** - No direct references to other aggregates
✅ **Protect invariants** - Enforce business rules in command methods
✅ **Clear aggregate boundaries** - Well-defined responsibilities

### Implementation Best Practices
✅ **Past-tense event names** - `Created`, not `Create`
✅ **Type hint everything** - Events, fields, method signatures
✅ **Validate before triggering** - Check invariants before `trigger_event()`
✅ **Events are data** - No business logic in event classes
✅ **Implement `_apply()`** - Handle all event types

### Testing Best Practices
✅ **Test creation** - Verify initial state and events
✅ **Test updates** - Verify state changes and events
✅ **Test validation** - Verify invariant protection
✅ **Test reconstruction** - Verify event sourcing with `mutate()`
✅ **Test edge cases** - Boundary conditions and error cases

### Project Structure Best Practices
✅ **Co-locate related code** - Keep aggregate, commands, tests together
✅ **Follow naming conventions** - Consistent file and class naming
✅ **Document complex rules** - Comments for non-obvious invariants
✅ **Keep events versioned** - Plan for event schema evolution

# Validation Examples

These examples show how to use this skill to validate aggregate implementations.

## Example 1: Validating a Simple Aggregate

**Scenario:** Review a GitHubInstallation aggregate implementation

**Validation Process:**
1. Check aggregate structure against Pattern 1 (Simple Aggregate)
2. Verify events use past tense: `Created`, `Suspended` ✅
3. Confirm validation happens before `trigger_event()` ✅
4. Check `_apply()` handles all event types ✅
5. Verify tests cover creation, state changes, reconstruction ✅

**Sample Code Being Validated:**
```python
# aggregate.py
from uuid import UUID
from eventsourcing.domain import Aggregate

class GitHubInstallation(Aggregate):
    def __init__(self, installation_id: int, account_login: str, tenant_id: str, **kwargs):
        super().__init__(**kwargs)
        self.installation_id = installation_id
        self.account_login = account_login
        self.tenant_id = tenant_id
        self.is_suspended = False

    class Created(Aggregate.Created):
        installation_id: int
        account_login: str
        tenant_id: str

    @classmethod
    def create(cls, installation_id: int, account_login: str, tenant_id: str) -> "GitHubInstallation":
        return cls._create(
            cls.Created,
            id=cls.create_id(),
            installation_id=installation_id,
            account_login=account_login,
            tenant_id=tenant_id
        )

    class Suspended(Aggregate.Event):
        pass

    def suspend(self) -> None:
        if self.is_suspended:
            raise ValueError("Installation already suspended")
        self.trigger_event(self.Suspended)

    def _apply(self, event: Aggregate.Event) -> None:
        super()._apply(event)
        if isinstance(event, self.Suspended):
            self.is_suspended = True
```

**Validation Result:**
- ✅ Follows Pattern 1 (Simple Aggregate)
- ✅ Events use past tense naming
- ✅ State transitions through events only
- ✅ Validation protects invariants
- ✅ Tests verify event sourcing behavior

## Example 2: Validating Business Rules Implementation

**Scenario:** Review a WidgetRegistryEndpoint aggregate with complex validation

**Validation Process:**
1. Match against Pattern 4 (Business Rules)
2. Check validation occurs BEFORE events (Pitfall 2) ✅
3. Verify business rules enforced: HTTPS check, tenant limits ✅
4. Confirm error messages are clear and actionable ✅
5. Check tests cover both valid and invalid cases ✅

**Sample Code Being Validated:**
```python
class WidgetRegistryEndpoint(Aggregate):
    MAX_PER_TENANT = 10

    def __init__(self, url: str, name: str, tenant_id: str, **kwargs):
        super().__init__(**kwargs)
        self.url = url
        self.name = name
        self.tenant_id = tenant_id
        self.is_active = True

    class Created(Aggregate.Created):
        url: str
        name: str
        tenant_id: str

    @classmethod
    def create(cls, url: str, name: str, tenant_id: str, existing_count: int) -> "WidgetRegistryEndpoint":
        if existing_count >= cls.MAX_PER_TENANT:
            raise ValueError(f"Maximum {cls.MAX_PER_TENANT} endpoints per tenant")

        if not url.startswith("https://"):
            raise ValueError("URL must use HTTPS protocol")

        if not name.strip():
            raise ValueError("Name cannot be empty")

        return cls._create(
            cls.Created,
            id=cls.create_id(),
            url=url,
            name=name,
            tenant_id=tenant_id
        )

    class UrlUpdated(Aggregate.Event):
        url: str

    def update_url(self, new_url: str) -> None:
        if not new_url.startswith("https://"):
            raise ValueError("URL must use HTTPS protocol")

        if new_url == self.url:
            return

        self.trigger_event(self.UrlUpdated, url=new_url)

    def _apply(self, event: Aggregate.Event) -> None:
        super()._apply(event)
        if isinstance(event, self.UrlUpdated):
            self.url = event.url
```

**Validation Result:**
- ✅ Matches Pattern 4 (Business Rules)
- ✅ Validation before `trigger_event()` (no Pitfall 2)
- ✅ Clear, actionable error messages
- ✅ Business constants documented (MAX_PER_TENANT)
- ✅ Tests verify both success and failure paths

## Example 3: Validating Collection Management

**Scenario:** Review a GitHubInstallation aggregate managing repository collections

**Validation Process:**
1. Match against Pattern 3 (Collections)
2. Verify collection operations use events, not direct mutation ✅
3. Check duplicate prevention before events ✅
4. Confirm `_apply()` maintains collection state ✅
5. Verify tests cover add, remove, and edge cases ✅

**Sample Code Being Validated:**
```python
class GitHubInstallation(Aggregate):
    def __init__(self, installation_id: int, **kwargs):
        super().__init__(**kwargs)
        self.installation_id = installation_id
        self.repositories: dict[int, str] = {}

    class RepositoryAdded(Aggregate.Event):
        repository_id: int
        repository_name: str
        repository_url: str

    def add_repository(self, repository_id: int, repository_name: str, repository_url: str) -> None:
        if repository_id in self.repositories:
            raise ValueError(f"Repository {repository_id} already added")

        self.trigger_event(
            self.RepositoryAdded,
            repository_id=repository_id,
            repository_name=repository_name,
            repository_url=repository_url
        )

    class RepositoryRemoved(Aggregate.Event):
        repository_id: int

    def remove_repository(self, repository_id: int) -> None:
        if repository_id not in self.repositories:
            raise ValueError(f"Repository {repository_id} not found")

        self.trigger_event(self.RepositoryRemoved, repository_id=repository_id)

    def _apply(self, event: Aggregate.Event) -> None:
        super()._apply(event)
        if isinstance(event, self.RepositoryAdded):
            self.repositories[event.repository_id] = event.repository_name
        elif isinstance(event, self.RepositoryRemoved):
            self.repositories.pop(event.repository_id, None)
```

**Validation Result:**
- ✅ Follows Pattern 3 (Collections)
- ✅ No direct collection mutation (no Pitfall 3)
- ✅ Validation prevents duplicates before events
- ✅ `_apply()` correctly maintains collection state
- ✅ Events include all necessary data (ID and name)

## Example 4: Identifying Anti-Patterns

**Scenario:** Code review finds potential issues in aggregate implementation

**Issues Found:**
1. ❌ State mutation without events (Pitfall 3)
   ```python
   def deactivate(self):
       self.is_active = False  # Direct mutation!
   ```
   **Fix:** Use `trigger_event(self.Deactivated)`

2. ❌ Validation after event (Pitfall 2)
   ```python
   def update_url(self, url: str):
       self.trigger_event(self.UrlUpdated, url=url)
       if not url.startswith("https://"):  # Too late!
           raise ValueError("Must be HTTPS")
   ```
   **Fix:** Move validation before `trigger_event()`

3. ❌ Missing `_apply()` implementation (Pitfall 1)
   ```python
   # No _apply() method found!
   ```
   **Fix:** Implement `_apply()` to handle events

**Validation Outcome:**
- ❌ Multiple anti-patterns detected
- 🔧 Use @eventsourcing-expert agent to refactor
- ✅ Re-validate after fixes applied

# Supporting Documentation

For advanced patterns and troubleshooting:
- [snapshot-strategies.md](snapshot-strategies.md) - Optimizing with snapshots
- [aggregate-patterns.md](aggregate-patterns.md) - Advanced aggregate designs
- [testing-guide.md](testing-guide.md) - Comprehensive testing strategies

---

# Skill Summary

## What This Skill Provides
- **4 Aggregate Patterns**: Simple, State Transitions, Collections, Business Rules
- **Anti-Patterns Catalog**: 6 common pitfalls with fixes
- **Validation Checklists**: Design, implementation, testing criteria
- **DDD Guidance**: Aggregate boundaries, invariants, consistency

## How to Use This Skill
1. **Pattern Reference**: Browse patterns to understand design options
2. **Validation Tool**: Review implementations against checklists
3. **Anti-Pattern Detection**: Identify common mistakes in code
4. **Agent Collaboration**: Use with @eventsourcing-expert for implementation

## Quick Validation Reference

| Validation Check | Look For | Anti-Pattern Risk |
|------------------|----------|-------------------|
| Event naming | Past tense (`Created`, `Updated`) | N/A |
| State changes | Only via `trigger_event()` | Pitfall 3: Direct mutation |
| Validation timing | Before `trigger_event()` | Pitfall 2: Validation after event |
| Event handling | `_apply()` implemented | Pitfall 1: Missing `_apply()` |
| Aggregate boundaries | Single responsibility, ID references only | Large aggregates, tight coupling |
| Testing | Creation, updates, validation, reconstruction | Incomplete test coverage |

## Pattern Selection Guide

| Use Case | Pattern | Key Feature |
|----------|---------|-------------|
| Basic entity tracking | Pattern 1: Simple | Minimal state, straightforward operations |
| Lifecycle management | Pattern 2: State Transitions | Explicit state enum, transition guards |
| Parent-child relationships | Pattern 3: Collections | Collection management via events |
| Complex validation | Pattern 4: Business Rules | Invariant protection, business constraints |
