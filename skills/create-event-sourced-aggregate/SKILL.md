---
name: Create Event-Sourced Aggregate
description: |
  Creates event-sourced aggregates using Python eventsourcing library with DDD patterns.
  Use this when: implementing new aggregates, creating domain entities with event sourcing, or building write models.
  Triggers: "create aggregate", "new aggregate", "event-sourced entity", "domain aggregate".
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, mcp__context7__resolve-library-id, mcp__context7__get-library-docs]
---

# Instructions

## Prerequisites
- Python eventsourcing library installed
- Understanding of Domain-Driven Design (DDD) concepts
- Knowledge of aggregate boundaries and invariants
- PostgreSQL database configured for event store

## Workflow

### Step 1: Fetch Eventsourcing Documentation
Always start by retrieving the latest library documentation:

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

This ensures all patterns follow official eventsourcing library best practices.

### Step 2: Define Aggregate Boundaries
Identify the aggregate's responsibility:

**Questions to Answer:**
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

### Step 3: Design Domain Events
Events represent state changes in past tense:

**Event Naming:**
- Use past tense: `Created`, `Updated`, `Deleted`, `Activated`
- Be domain-specific: `GitHubInstallationCreated`, `WidgetRegistryEndpointActivated`
- Capture meaningful business events, not CRUD operations

**Event Structure:**
```python
from eventsourcing.domain import Aggregate

class MyAggregate(Aggregate):
    class EventName(Aggregate.Event):
        field1: str
        field2: int
        field3: Optional[UUID]
```

**Event Best Practices:**
- Immutable (use frozen dataclasses)
- Past-tense names
- Include all data needed for projections
- Type hints for all fields
- No business logic in events

### Step 4: Implement Aggregate
Create the aggregate class following the template:

**File Location:**
```
apps/registry/<bounded_context>/<aggregate_name>/
├── aggregate.py              # Aggregate implementation
├── commands.py               # Command handlers
├── tests/
│   └── test_<aggregate>_aggregate.py
```

**Aggregate Template:**
```python
from uuid import UUID
from typing import Optional
from eventsourcing.domain import Aggregate

class MyAggregate(Aggregate):
    def __init__(self, field1: str, field2: int, **kwargs):
        super().__init__(**kwargs)
        self.field1 = field1
        self.field2 = field2

    class Created(Aggregate.Created):
        field1: str
        field2: int

    @classmethod
    def create(cls, field1: str, field2: int) -> "MyAggregate":
        return cls._create(
            cls.Created,
            id=cls.create_id(),
            field1=field1,
            field2=field2
        )

    class Updated(Aggregate.Event):
        field1: str

    def update_field1(self, new_value: str) -> None:
        if not new_value:
            raise ValueError("Field1 cannot be empty")

        self.trigger_event(
            self.Updated,
            field1=new_value
        )

    def _apply(self, event: Aggregate.Event) -> None:
        super()._apply(event)
        if isinstance(event, self.Updated):
            self.field1 = event.field1
```

**Key Implementation Points:**
- Inherit from `Aggregate`
- Define events as nested classes
- Use `@classmethod create()` for creation
- Use `trigger_event()` to emit events
- Implement `_apply()` for event handling
- Protect invariants in command methods
- Raise domain exceptions for validation errors

### Step 5: Create Command Handlers
Implement command handlers in `commands.py`:

**Command Handler Template:**
```python
from uuid import UUID
from apps.core.cqrs.command import CommandHandler, command_handler
from apps.core.cqrs.commands import Command
from .aggregate import MyAggregate

class CreateMyAggregateCommand(Command):
    field1: str
    field2: int

class CreateMyAggregateHandler(CommandHandler[CreateMyAggregateCommand]):
    @command_handler
    def handle(self, command: CreateMyAggregateCommand) -> UUID:
        aggregate = MyAggregate.create(
            field1=command.field1,
            field2=command.field2
        )
        self.repository.save(aggregate)
        return aggregate.id

class UpdateMyAggregateCommand(Command):
    aggregate_id: UUID
    field1: str

class UpdateMyAggregateHandler(CommandHandler[UpdateMyAggregateCommand]):
    @command_handler
    def handle(self, command: UpdateMyAggregateCommand) -> None:
        aggregate = self.repository.get(command.aggregate_id)
        aggregate.update_field1(command.field1)
        self.repository.save(aggregate)
```

### Step 6: Write Tests
Create comprehensive tests in `tests/test_<aggregate>_aggregate.py`:

**Test Template:**
```python
import pytest
from uuid import UUID
from .aggregate import MyAggregate

def test_create_aggregate():
    aggregate = MyAggregate.create(
        field1="test value",
        field2=42
    )

    assert isinstance(aggregate.id, UUID)
    assert aggregate.field1 == "test value"
    assert aggregate.field2 == 42

    assert len(aggregate.pending_events) == 1
    event = aggregate.pending_events[0]
    assert isinstance(event, MyAggregate.Created)
    assert event.field1 == "test value"
    assert event.field2 == 42

def test_update_field1():
    aggregate = MyAggregate.create(field1="initial", field2=10)
    aggregate.collect_events()

    aggregate.update_field1("updated")

    assert aggregate.field1 == "updated"
    assert len(aggregate.pending_events) == 1
    assert isinstance(aggregate.pending_events[0], MyAggregate.Updated)

def test_update_field1_validation():
    aggregate = MyAggregate.create(field1="initial", field2=10)

    with pytest.raises(ValueError, match="Field1 cannot be empty"):
        aggregate.update_field1("")

def test_event_sourcing_reconstruction():
    aggregate = MyAggregate.create(field1="initial", field2=10)
    events = aggregate.collect_events()

    aggregate.update_field1("updated")
    events.extend(aggregate.collect_events())

    reconstructed = MyAggregate.mutate(None, *events)

    assert reconstructed.field1 == "updated"
    assert reconstructed.field2 == 10
```

### Step 7: Run Tests and Validation

Execute tests to verify implementation:

```bash
pytest apps/registry/<bounded_context>/<aggregate_name>/tests/ -v
```

Run code quality checks:

```bash
flake8 apps/registry/<bounded_context>/<aggregate_name>/
```

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

## Best Practices

### DO:
✅ **Keep aggregates small** - Focus on single responsibility
✅ **Protect invariants** - Validate in command methods before triggering events
✅ **Use past-tense event names** - `Created`, not `Create`
✅ **Type hint everything** - Events, fields, method signatures
✅ **Test event sourcing** - Verify reconstruction from events
✅ **Raise domain exceptions** - Clear validation errors
✅ **Follow project structure** - Co-locate aggregate, commands, tests

### DON'T:
❌ **Don't put logic in events** - Events are data, not behavior
❌ **Don't reference other aggregates directly** - Use IDs only
❌ **Don't skip validation** - Protect invariants in command methods
❌ **Don't use present tense for events** - Always past tense
❌ **Don't forget tests** - Test creation, updates, validation, reconstruction
❌ **Don't violate aggregate boundaries** - One aggregate per consistency boundary

## Common Pitfalls

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

# Examples

## Example 1: Creating a Simple Aggregate

**User Request:** "Create an aggregate for tracking GitHub installations"

**Actions Taken:**
1. Fetched eventsourcing documentation on aggregates
2. Defined aggregate boundary: GitHubInstallation
3. Designed events: `Created`, `Suspended`, `Deleted`
4. Implemented aggregate in `apps/registry/github_integration/installation/aggregate.py`
5. Created command handlers in `commands.py`
6. Wrote tests covering creation, suspension, deletion
7. Ran pytest - all tests passing

**Code Created:**
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

**Expected Outcome:**
- Aggregate created following eventsourcing patterns
- Events properly defined and triggered
- State transitions handled in _apply()
- Tests verify event sourcing reconstruction
- All tests passing, code follows PEP 8

## Example 2: Aggregate with Validation Rules

**User Request:** "Create aggregate for widget registry endpoints with URL validation"

**Actions Taken:**
1. Fetched documentation on aggregate patterns
2. Defined validation rules: HTTPS only, max 10 per tenant
3. Implemented aggregate with business rules
4. Added validation in create() and update methods
5. Created tests for valid and invalid scenarios

**Code Created:**
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

**Expected Outcome:**
- Business rules enforced before events
- Clear validation errors
- Tests cover both valid and invalid inputs
- Aggregate protects data integrity

## Example 3: Aggregate with Child Entities

**User Request:** "Aggregate that manages GitHub repositories within an installation"

**Actions Taken:**
1. Fetched eventsourcing docs on collection handling
2. Designed events for add/remove repositories
3. Implemented aggregate with repository collection
4. Created tests for collection operations

**Code Created:**
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

**Expected Outcome:**
- Collection managed through events
- Add/remove operations properly validated
- State reconstructed correctly from events
- Tests verify collection operations

# Supporting Documentation

For advanced patterns and troubleshooting:
- [snapshot-strategies.md](snapshot-strategies.md) - Optimizing with snapshots
- [aggregate-patterns.md](aggregate-patterns.md) - Advanced aggregate designs
- [testing-guide.md](testing-guide.md) - Comprehensive testing strategies

---

**Quick Reference:**

| Task | Method | Notes |
|------|--------|-------|
| Create aggregate | `@classmethod create()` | Use `_create()` helper |
| Emit event | `trigger_event()` | Before validation |
| Apply event | `_apply()` | Update state here |
| Validate | In command method | Before `trigger_event()` |
| Test | pytest | Cover creation, updates, validation, reconstruction |
