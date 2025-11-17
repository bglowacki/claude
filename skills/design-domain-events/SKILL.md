---
name: Design Domain Events
description: |
  Designs domain events for event-sourced aggregates following DDD and eventsourcing library patterns.
  Use this when: defining new events, refactoring event structure, or ensuring event design best practices.
  Triggers: "design event", "create event", "event definition", "domain event schema".
allowed-tools: [Read, Grep, Glob, mcp__context7__resolve-library-id, mcp__context7__get-library-docs]
---

# Instructions

## Prerequisites
- Understanding of Domain-Driven Design (DDD)
- Knowledge of event sourcing principles
- Familiarity with aggregate boundaries
- Python eventsourcing library basics

## Workflow

### Step 1: Fetch Eventsourcing Documentation

```python
# Resolve library ID
mcp__context7__resolve-library-id(libraryName="eventsourcing")

# Fetch event documentation
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/pyeventsourcing/eventsourcing",
    topic="events",
    page=1
)
```

### Step 2: Understand Event Purpose

**Key Questions:**
- What business-meaningful change occurred?
- What state changed in the aggregate?
- What data is needed for projections?
- What data is needed for event replay?
- Is this a creation, modification, or deletion event?

**Event Categories:**
- **Lifecycle Events**: `Created`, `Activated`, `Suspended`, `Deleted`
- **State Change Events**: `StatusChanged`, `FieldUpdated`, `PropertyModified`
- **Relationship Events**: `ItemAdded`, `ItemRemoved`, `AssociationCreated`
- **Business Events**: `OrderPlaced`, `PaymentReceived`, `InstallationCompleted`

### Step 3: Name Events Properly

**Naming Rules:**
1. **Past Tense**: Events describe what HAPPENED
2. **Domain Language**: Use ubiquitous language from bounded context
3. **Specific**: Avoid generic names like `Updated` or `Changed`
4. **Meaningful**: Name should indicate business significance

**Examples:**

✅ **Good Event Names:**
- `GitHubInstallationCreated` (specific, past tense, domain term)
- `WidgetRegistryEndpointActivated` (action + state change)
- `RepositoryAdded` (relationship change, domain action)
- `InstallationSuspended` (lifecycle event, business meaning)

❌ **Bad Event Names:**
- `Created` (too generic - created what?)
- `Update` (present tense, not past)
- `Change` (vague - what changed?)
- `DataModified` (technical, not domain-focused)

### Step 4: Design Event Structure

Events are defined as nested classes within aggregates:

**Basic Template:**
```python
from eventsourcing.domain import Aggregate
from typing import Optional
from uuid import UUID
from datetime import datetime

class MyAggregate(Aggregate):
    class MyEventHappened(Aggregate.Event):
        field1: str
        field2: int
        field3: Optional[UUID] = None
        field4: list[str] = []
```

**Event Field Guidelines:**
- Include ALL data needed for projections
- Include ALL data needed for aggregate reconstruction
- Use type hints for every field
- Use Optional for nullable fields
- Provide defaults for optional fields
- Keep events immutable (no mutable defaults)

### Step 5: Choose Appropriate Event Types

**Aggregate.Created Event:**
```python
class Created(Aggregate.Created):
    field1: str
    field2: int
    tenant_id: str
```

**Used for**: Initial aggregate creation
**Inherited fields**: `originator_id`, `originator_version`, `timestamp`

**Aggregate.Event (Standard Event):**
```python
class FieldUpdated(Aggregate.Event):
    new_value: str
    old_value: Optional[str] = None
```

**Used for**: State changes, updates, relationships
**Inherited fields**: `originator_id`, `originator_version`, `timestamp`

**Aggregate.Deleted Event** (if using soft deletes):
```python
class Deleted(Aggregate.Event):
    deleted_by: str
    reason: Optional[str] = None
```

### Step 6: Design Event Data

**Include in Event:**
- ✅ All fields that changed
- ✅ Context needed for projections
- ✅ Business-meaningful metadata
- ✅ Identifiers for related entities (by ID, not objects)
- ✅ Tenant/user context
- ✅ Timestamps (auto-included)

**DON'T Include in Event:**
- ❌ Derived/computed values (calculate in projection if needed)
- ❌ Entire object graphs (use IDs)
- ❌ Mutable collections without defaults
- ❌ Secrets or sensitive data (encrypt if necessary)
- ❌ Technical implementation details

**Example - Good Event Design:**
```python
class WidgetRegistryEndpointCreated(Aggregate.Created):
    url: str
    name: str
    tenant_id: str
    auth_type: str
    is_active: bool = True
    created_by: Optional[str] = None
```

**Example - Problematic Event Design:**
```python
class WidgetRegistryEndpointCreated(Aggregate.Created):
    url: str
    name: str
    tenant_id: str
    # ❌ Mutable default
    headers: dict = {}
    # ❌ Derived value (should calculate in projection)
    url_hash: str
    # ❌ Sensitive data
    api_key: str
```

### Step 7: Handle Complex Data Types

**UUID Fields:**
```python
from uuid import UUID

class RepositoryAdded(Aggregate.Event):
    repository_id: int
    installation_id: UUID  # Reference to other aggregate
    owner_id: Optional[UUID] = None
```

**Enum Fields:**
```python
from enum import Enum

class Status(str, Enum):
    PENDING = "pending"
    ACTIVE = "active"
    SUSPENDED = "suspended"

class StatusChanged(Aggregate.Event):
    old_status: Status
    new_status: Status
    reason: Optional[str] = None
```

**Datetime Fields:**
```python
from datetime import datetime

class InstallationActivated(Aggregate.Event):
    activated_at: datetime
    activated_by: str
```

**Collection Fields:**
```python
class RepositoriesUpdated(Aggregate.Event):
    added_repository_ids: list[int] = []
    removed_repository_ids: list[int] = []
```

**Note**: Use immutable defaults (`= []` is safe in dataclass, but prefer `= field(default_factory=list)` if using dataclasses)

### Step 8: Document Event Purpose (in Code)

Use type hints and meaningful names instead of docstrings:

✅ **Self-Documenting:**
```python
class InstallationSuspendedByUser(Aggregate.Event):
    suspended_by_user_id: str
    suspension_reason: str
    suspension_timestamp: datetime
    is_permanent_suspension: bool = False
```

❌ **Needs Explanation:**
```python
class Suspended(Aggregate.Event):
    user: str
    reason: str
    when: datetime
    perm: bool = False
```

## Event Design Patterns

### Pattern 1: Creation Event
```python
class GitHubInstallationCreated(Aggregate.Created):
    installation_id: int
    account_login: str
    account_type: str
    tenant_id: str
    installed_at: datetime
```

**Characteristics:**
- Inherits from `Aggregate.Created`
- Contains all initial state
- Includes business identifiers
- Sets aggregate foundation

### Pattern 2: Simple State Change
```python
class UrlUpdated(Aggregate.Event):
    new_url: str
    old_url: str
```

**Characteristics:**
- Single field update
- May include old value for audit
- Focused on one change

### Pattern 3: Status Transition
```python
class InstallationSuspended(Aggregate.Event):
    suspended_by: str
    suspension_reason: str
    can_reactivate: bool = True
```

**Characteristics:**
- Lifecycle state change
- Includes actor (who did it)
- Includes reason/context
- May include permissions

### Pattern 4: Relationship Change
```python
class RepositoryAdded(Aggregate.Event):
    repository_id: int
    repository_name: str
    repository_url: str
    repository_owner: str
```

**Characteristics:**
- Adds related entity
- Includes entity details
- Maintains relationship data

### Pattern 5: Batch Operation
```python
class RepositoriesSynchronized(Aggregate.Event):
    added_repositories: list[dict[str, any]]
    removed_repository_ids: list[int]
    sync_timestamp: datetime
```

**Characteristics:**
- Multiple changes in one event
- Collections of adds/removes
- Timestamp for sync tracking

### Pattern 6: Business Process Completion
```python
class InstallationFlowCompleted(Aggregate.Event):
    flow_id: UUID
    completion_timestamp: datetime
    repositories_configured: int
    webhooks_configured: int
```

**Characteristics:**
- Marks process completion
- Includes summary metrics
- Business milestone event

## Best Practices

### DO:
✅ **Use past tense** - `Created`, not `Create`
✅ **Be specific** - `RepositoryAdded`, not `Updated`
✅ **Include context** - tenant_id, user_id, timestamps
✅ **Type hint everything** - All fields with proper types
✅ **Provide defaults** - For optional fields
✅ **Keep immutable** - No methods, just data
✅ **Domain language** - Use ubiquitous language
✅ **Capture intent** - Why change happened, not just what

### DON'T:
❌ **Don't use present tense** - `Creating` is wrong
❌ **Don't be generic** - `Updated` tells us nothing
❌ **Don't skip type hints** - Untyped fields cause errors
❌ **Don't include mutable defaults** - dict={} is dangerous
❌ **Don't add business logic** - Events are pure data
❌ **Don't use technical terms** - Use domain language
❌ **Don't expose internals** - Hide implementation details

## Common Mistakes

### Mistake 1: Present Tense Names
❌ **Wrong:**
```python
class Create(Aggregate.Created):
    pass

class Updating(Aggregate.Event):
    pass
```

✅ **Correct:**
```python
class Created(Aggregate.Created):
    pass

class Updated(Aggregate.Event):
    pass
```

### Mistake 2: Missing Type Hints
❌ **Wrong:**
```python
class Created(Aggregate.Created):
    url = None
    name = ""
    count = 0
```

✅ **Correct:**
```python
class Created(Aggregate.Created):
    url: str
    name: str
    count: int
```

### Mistake 3: Mutable Defaults
❌ **Wrong:**
```python
class RepositoriesAdded(Aggregate.Event):
    repository_ids: list = []  # Dangerous in non-dataclass
```

✅ **Correct:**
```python
from dataclasses import field

class RepositoriesAdded(Aggregate.Event):
    repository_ids: list[int] = field(default_factory=list)
```

### Mistake 4: Too Generic
❌ **Wrong:**
```python
class Changed(Aggregate.Event):
    field: str
    value: any
```

✅ **Correct:**
```python
class NameChanged(Aggregate.Event):
    new_name: str
    old_name: str

class UrlChanged(Aggregate.Event):
    new_url: str
    old_url: str
```

### Mistake 5: Including Derived Data
❌ **Wrong:**
```python
class Created(Aggregate.Created):
    url: str
    url_hash: str  # ❌ Derived from url
    url_domain: str  # ❌ Derived from url
```

✅ **Correct:**
```python
class Created(Aggregate.Created):
    url: str
    # Compute hash/domain in projection or query if needed
```

## Event Evolution

### Adding New Fields (Safe)
```python
# V1
class Created(Aggregate.Created):
    name: str
    url: str

# V2 (backward compatible)
class Created(Aggregate.Created):
    name: str
    url: str
    description: Optional[str] = None  # New optional field
```

### Renaming Fields (Requires Migration)
```python
# V1
class Created(Aggregate.Created):
    installation_number: int

# V2 (breaking change - need event migration)
class Created(Aggregate.Created):
    installation_id: int  # ⚠️ Renamed field
```

**Best Practice**: Add new field with default, deprecate old field over time.

# Examples

## Example 1: GitHub Installation Events

**Domain**: GitHub Integration
**Aggregate**: GitHubInstallation

**Events Designed:**
```python
class GitHubInstallation(Aggregate):
    class Created(Aggregate.Created):
        installation_id: int
        account_login: str
        account_type: str
        tenant_id: str
        installed_at: datetime

    class Suspended(Aggregate.Event):
        suspended_by: str
        suspension_reason: str

    class Reactivated(Aggregate.Event):
        reactivated_by: str

    class RepositoryAdded(Aggregate.Event):
        repository_id: int
        repository_name: str
        repository_url: str
        repository_is_private: bool

    class RepositoryRemoved(Aggregate.Event):
        repository_id: int
        removal_reason: Optional[str] = None
```

**Why Good:**
- Past tense names
- Domain-specific language
- All fields typed
- Includes business context
- Captures actor (who did it)
- Separates concerns (one event per action)

## Example 2: Widget Registry Events

**Domain**: Widget Registry
**Aggregate**: WidgetRegistryEndpoint

**Events Designed:**
```python
class WidgetRegistryEndpoint(Aggregate):
    class Created(Aggregate.Created):
        url: str
        name: str
        tenant_id: str
        auth_type: str
        is_active: bool = True

    class Activated(Aggregate.Event):
        activated_by: str
        activation_timestamp: datetime

    class Deactivated(Aggregate.Event):
        deactivated_by: str
        deactivation_reason: str

    class UrlChanged(Aggregate.Event):
        new_url: str
        old_url: str
        changed_by: str

    class Deleted(Aggregate.Event):
        deleted_by: str
        deletion_reason: Optional[str] = None
```

**Why Good:**
- Lifecycle events (Created, Activated, Deactivated, Deleted)
- Includes audit trail (who performed action)
- Captures business reason where applicable
- Maintains old/new values for important changes

## Example 3: Installation Flow Events

**Domain**: Installation Flow
**Aggregate**: InstallationFlow

**Events Designed:**
```python
class InstallationFlow(Aggregate):
    class Started(Aggregate.Created):
        tenant_id: str
        installation_id: int
        started_by: str

    class RepositorySelectionCompleted(Aggregate.Event):
        selected_repository_ids: list[int]
        total_repositories_available: int

    class WebhookConfigurationCompleted(Aggregate.Event):
        configured_webhooks: list[str]

    class Completed(Aggregate.Event):
        completion_timestamp: datetime
        repositories_configured: int
        webhooks_configured: int

    class Abandoned(Aggregate.Event):
        abandoned_at: datetime
        abandonment_reason: str
        last_completed_step: str
```

**Why Good:**
- Process flow captured in events
- Each step has dedicated event
- Completion event summarizes results
- Abandonment tracked with context

# Quick Reference

**Event Naming Checklist:**
- [ ] Past tense?
- [ ] Domain-specific?
- [ ] Describes business change?
- [ ] Not generic (Updated/Changed)?

**Event Structure Checklist:**
- [ ] All fields have type hints?
- [ ] Optional fields have defaults?
- [ ] No mutable defaults?
- [ ] No derived/computed data?
- [ ] Includes business context?
- [ ] Includes actor (who did it)?

**Event Testing:**
- [ ] Can reconstruct aggregate from events?
- [ ] Projections have all needed data?
- [ ] Event is immutable?
- [ ] Type hints work with mypy?
