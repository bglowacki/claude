---
name: Setup Event Sourcing Projection
description: |
  Creates CQRS projections that map events to Django read models using Python eventsourcing library.
  Use this when: implementing read models, creating projections from events, or bridging write/read sides in CQRS.
  Triggers: "create projection", "setup projection", "event to read model", "CQRS read side".
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, mcp__context7__resolve-library-id, mcp__context7__get-library-docs]
---

# Instructions

## Prerequisites
- Python eventsourcing library installed
- Django models for read side defined
- Event-sourced aggregate implementation
- Understanding of CQRS (Command Query Responsibility Segregation)
- Projection runner sidecar container configured

## CQRS Architecture Overview

```
Write Side (Commands)
  HTTP POST → CommandBus → CommandHandler → Aggregate → Events → Event Store

Read Side (Queries)
  HTTP GET → QueryBus → QueryHandler → Repository → Django Read Model → Response

Bridge (Projections)
  Event Store → ProjectionRunner (sidecar) → Projection → Django Read Model
```

**Key Concept**: Projections convert events (write side) into queryable Django models (read side).

## Workflow

### Step 1: Fetch Eventsourcing Documentation

```python
# Resolve library ID
mcp__context7__resolve-library-id(libraryName="eventsourcing")

# Fetch projection documentation
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/pyeventsourcing/eventsourcing",
    topic="projections",
    page=1
)
```

### Step 2: Understand Projection Co-Location Pattern

**Directory Structure** (co-locate with aggregate):
```
apps/registry/<bounded_context>/<aggregate>/
├── aggregate.py              # Event-sourced aggregate (write model)
├── commands.py               # Command handlers
├── projection.py             # Event → Read Model mapper (CQRS bridge)
├── read_model_interface.py   # Abstract read model interface
├── django_read_model.py      # Django ORM implementation (read model)
├── models.py                 # Django models (read model database schema)
└── tests/
    └── test_<aggregate>_projection.py
```

**Organization Principles:**
- ✅ Co-locate projections with their source aggregates
- ✅ Organize by domain boundaries (bounded contexts)
- ✅ One aggregate can have multiple projections
- ❌ Don't centralize projections away from aggregates

### Step 3: Create Read Model Interface

Define abstract interface for testability:

**File**: `read_model_interface.py`

```python
from abc import ABC, abstractmethod
from uuid import UUID
from datetime import datetime

class MyAggregateReadModelInterface(ABC):
    @abstractmethod
    def create_my_entity(
        self,
        aggregate_id: UUID,
        field1: str,
        field2: int,
        created_at: datetime
    ) -> None:
        pass

    @abstractmethod
    def update_field1(self, aggregate_id: UUID, field1: str) -> None:
        pass

    @abstractmethod
    def delete_my_entity(self, aggregate_id: UUID) -> None:
        pass
```

**Interface Guidelines:**
- One method per event type
- Accept aggregate_id as first parameter
- Include all fields needed from event
- Use type hints for all parameters
- No implementation details

### Step 4: Create Projection Class

Map events to read model operations:

**File**: `projection.py`

```python
from eventsourcing.projection import Projection
from eventsourcing.utils import get_topic
from eventsourcing.system import ProcessApplication

from .aggregate import MyAggregate
from .read_model_interface import MyAggregateReadModelInterface

class MyAggregateProjection(Projection[MyAggregateReadModelInterface]):
    name = "my_aggregate"

    topics = (
        get_topic(MyAggregate.Created),
        get_topic(MyAggregate.Updated),
        get_topic(MyAggregate.Deleted),
    )

    @process_event.register
    def _(self, event: MyAggregate.Created, tracking: Tracking) -> None:
        self.view.create_my_entity(
            aggregate_id=event.originator_id,
            field1=event.field1,
            field2=event.field2,
            created_at=event.timestamp
        )

    @process_event.register
    def _(self, event: MyAggregate.Updated, tracking: Tracking) -> None:
        self.view.update_field1(
            aggregate_id=event.originator_id,
            field1=event.field1
        )

    @process_event.register
    def _(self, event: MyAggregate.Deleted, tracking: Tracking) -> None:
        self.view.delete_my_entity(aggregate_id=event.originator_id)
```

**Projection Patterns:**
- Inherit from `Projection[InterfaceType]`
- Define unique `name` property
- List event `topics` to subscribe to
- Use `@process_event.register` for event handlers
- Call read model interface methods (don't access Django directly)
- Keep logic minimal - just map event data to read model

### Step 5: Create Django Read Model Implementation

Implement interface using Django ORM:

**File**: `django_read_model.py`

```python
from uuid import UUID
from datetime import datetime
from django.db import transaction

from apps.core.tracking import PostgresTrackingRecorder
from .read_model_interface import MyAggregateReadModelInterface
from .models import MyDjangoModel

class DjangoMyAggregateReadModel(MyAggregateReadModelInterface, PostgresTrackingRecorder):
    def create_my_entity(
        self,
        aggregate_id: UUID,
        field1: str,
        field2: int,
        created_at: datetime
    ) -> None:
        with transaction.atomic():
            MyDjangoModel.objects.update_or_create(
                aggregate_id=str(aggregate_id),
                defaults={
                    "field1": field1,
                    "field2": field2,
                    "created_at": created_at,
                }
            )

    def update_field1(self, aggregate_id: UUID, field1: str) -> None:
        with transaction.atomic():
            MyDjangoModel.objects.filter(
                aggregate_id=str(aggregate_id)
            ).update(field1=field1)

    def delete_my_entity(self, aggregate_id: UUID) -> None:
        with transaction.atomic():
            MyDjangoModel.objects.filter(
                aggregate_id=str(aggregate_id)
            ).delete()
```

**Django Implementation Guidelines:**
- Inherit from interface AND `PostgresTrackingRecorder`
- Use `transaction.atomic()` for all operations
- Use `update_or_create()` for idempotency
- Convert UUID to string for Django models
- Handle not-found cases gracefully

### Step 6: Define Django Model (if not exists)

Create database schema for read model:

**File**: `models.py`

```python
from django.db import models
from uuid import uuid4

class MyDjangoModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    aggregate_id = models.CharField(max_length=255, unique=True, db_index=True)
    field1 = models.CharField(max_length=255)
    field2 = models.IntegerField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "my_table"
        indexes = [
            models.Index(fields=["aggregate_id"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self):
        return f"{self.field1} ({self.aggregate_id})"
```

**Django Model Guidelines:**
- Always include `aggregate_id` field (link to event stream)
- Index `aggregate_id` for lookups
- Use UUIDs for primary keys
- Add indexes for query patterns
- Include timestamps for audit trail

### Step 7: Create Database Migration

Generate and apply migration:

```bash
python manage.py makemigrations
python manage.py migrate
```

### Step 8: Register Projection with Runner

Add projection to projection runner configuration:

**File**: `apps/registry/projections.py` (or similar)

```python
from apps.registry.<bounded_context>.<aggregate>.projection import MyAggregateProjection
from apps.registry.<bounded_context>.<aggregate>.django_read_model import DjangoMyAggregateReadModel

PROJECTIONS = [
    (MyAggregateProjection, DjangoMyAggregateReadModel),
    # ... other projections
]
```

### Step 9: Write Tests

Create comprehensive projection tests:

**File**: `tests/test_<aggregate>_projection.py`

```python
import pytest
from unittest.mock import Mock
from uuid import UUID, uuid4
from datetime import datetime

from ..projection import MyAggregateProjection
from ..aggregate import MyAggregate
from ..read_model_interface import MyAggregateReadModelInterface

@pytest.fixture
def mock_read_model():
    return Mock(spec=MyAggregateReadModelInterface)

@pytest.fixture
def projection(mock_read_model):
    return MyAggregateProjection(view=mock_read_model)

def test_projection_handles_created_event(projection, mock_read_model):
    aggregate_id = uuid4()
    event = MyAggregate.Created(
        originator_id=aggregate_id,
        originator_version=1,
        timestamp=datetime.now(),
        field1="test",
        field2=42
    )

    projection.process_event(event, tracking=None)

    mock_read_model.create_my_entity.assert_called_once_with(
        aggregate_id=aggregate_id,
        field1="test",
        field2=42,
        created_at=event.timestamp
    )

def test_projection_handles_updated_event(projection, mock_read_model):
    aggregate_id = uuid4()
    event = MyAggregate.Updated(
        originator_id=aggregate_id,
        originator_version=2,
        timestamp=datetime.now(),
        field1="updated"
    )

    projection.process_event(event, tracking=None)

    mock_read_model.update_field1.assert_called_once_with(
        aggregate_id=aggregate_id,
        field1="updated"
    )

def test_projection_handles_deleted_event(projection, mock_read_model):
    aggregate_id = uuid4()
    event = MyAggregate.Deleted(
        originator_id=aggregate_id,
        originator_version=3,
        timestamp=datetime.now()
    )

    projection.process_event(event, tracking=None)

    mock_read_model.delete_my_entity.assert_called_once_with(aggregate_id=aggregate_id)
```

### Step 10: Verify Projection

Run tests:

```bash
pytest apps/registry/<bounded_context>/<aggregate>/tests/test_*_projection.py -v
```

Test manually with projection runner:

```bash
# Run projection runner (in sidecar container or locally)
python manage.py run_projections
```

## Projection Patterns

### Pattern 1: Simple Event-to-Model Projection

One event type → one Django model:

```python
class InstallationProjection(Projection[InstallationReadModelInterface]):
    name = "installation"

    topics = (
        get_topic(GitHubInstallation.Created),
        get_topic(GitHubInstallation.Suspended),
    )

    @process_event.register
    def _(self, event: GitHubInstallation.Created, tracking: Tracking) -> None:
        self.view.create_installation(
            aggregate_id=event.originator_id,
            installation_id=event.installation_id,
            account_login=event.account_login,
            tenant_id=event.tenant_id
        )

    @process_event.register
    def _(self, event: GitHubInstallation.Suspended, tracking: Tracking) -> None:
        self.view.suspend_installation(aggregate_id=event.originator_id)
```

### Pattern 2: Denormalization Projection

Multiple events → single denormalized Django model:

```python
class GithubRepositoryProjection(Projection[GithubRepositoryReadModelInterface]):
    name = "github_repository"

    topics = (
        get_topic(GitHubInstallation.RepositoryAdded),
        get_topic(GitHubInstallation.RepositoryUpdated),
        get_topic(GitHubInstallation.RepositoryRemoved),
    )

    @process_event.register
    def _(self, event: GitHubInstallation.RepositoryAdded, tracking: Tracking) -> None:
        self.view.create_repository(
            installation_id=event.originator_id,
            repository_id=event.repository_id,
            repository_name=event.repository_name,
            repository_url=event.repository_url
        )
```

**Note**: This is denormalization (separate view from same aggregate), NOT a cross-aggregate projection.

### Pattern 3: Aggregate Filtering

Only project specific events based on conditions:

```python
class ActiveEndpointsProjection(Projection[ActiveEndpointsReadModelInterface]):
    name = "active_endpoints"

    topics = (
        get_topic(WidgetRegistryEndpoint.Created),
        get_topic(WidgetRegistryEndpoint.Activated),
        get_topic(WidgetRegistryEndpoint.Deactivated),
    )

    @process_event.register
    def _(self, event: WidgetRegistryEndpoint.Created, tracking: Tracking) -> None:
        # Only project if active
        if event.is_active:
            self.view.create_endpoint(...)

    @process_event.register
    def _(self, event: WidgetRegistryEndpoint.Deactivated, tracking: Tracking) -> None:
        self.view.remove_endpoint(aggregate_id=event.originator_id)
```

### Pattern 4: Cross-Aggregate Projection (Advanced)

Subscribes to events from **multiple aggregate types**:

**When to Use**: Analytics, reporting, composite views

**Directory**: `apps/registry/shared/projections/tenant_activity/`

```python
from apps.registry.widget_registry_endpoint.aggregate import WidgetRegistryEndpoint
from apps.registry.github_integration.installation.aggregate import GitHubInstallation

class TenantActivityProjection(Projection[TenantActivityReadModelInterface]):
    name = "tenant_activity"

    topics = (
        # Multiple aggregate types
        get_topic(WidgetRegistryEndpoint.Created),
        get_topic(GitHubInstallation.Created),
    )

    @process_event.register
    def _(self, event: WidgetRegistryEndpoint.Created, tracking: Tracking) -> None:
        self.view.record_activity(
            tenant_id=event.tenant_id,
            activity_type="endpoint_created",
            aggregate_id=event.originator_id
        )

    @process_event.register
    def _(self, event: GitHubInstallation.Created, tracking: Tracking) -> None:
        self.view.record_activity(
            tenant_id=event.tenant_id,
            activity_type="installation_created",
            aggregate_id=event.originator_id
        )
```

## Best Practices

### DO:
✅ **Co-locate with aggregates** - Keep projection near source aggregate
✅ **Use interfaces** - Abstract for testability
✅ **Use transactions** - Wrap Django operations in `transaction.atomic()`
✅ **Idempotent operations** - Use `update_or_create()` for replay safety
✅ **Test with mocks** - Unit test projections independently
✅ **Index aggregate_id** - Fast lookups by event stream
✅ **Separate write/read** - Never query aggregates from API endpoints

### DON'T:
❌ **Don't put business logic in projections** - Just map data
❌ **Don't access Django models directly from projection** - Use interface
❌ **Don't centralize projections** - Organize by domain boundaries
❌ **Don't skip transactions** - Risk inconsistent state
❌ **Don't forget idempotency** - Projections must handle replays
❌ **Don't query aggregates from API** - Use projections/read models

## Common Pitfalls

### Pitfall 1: No Transaction Wrapping
❌ **Wrong:**
```python
def create_entity(self, aggregate_id: UUID, name: str) -> None:
    MyModel.objects.create(aggregate_id=str(aggregate_id), name=name)
    # If second operation fails, first is already committed
    RelatedModel.objects.create(entity_id=aggregate_id)
```

✅ **Correct:**
```python
def create_entity(self, aggregate_id: UUID, name: str) -> None:
    with transaction.atomic():
        MyModel.objects.update_or_create(
            aggregate_id=str(aggregate_id),
            defaults={"name": name}
        )
        RelatedModel.objects.update_or_create(entity_id=aggregate_id)
```

### Pitfall 2: Not Idempotent
❌ **Wrong:**
```python
def create_entity(self, aggregate_id: UUID, name: str) -> None:
    MyModel.objects.create(aggregate_id=str(aggregate_id), name=name)
    # Replay causes IntegrityError
```

✅ **Correct:**
```python
def create_entity(self, aggregate_id: UUID, name: str) -> None:
    MyModel.objects.update_or_create(
        aggregate_id=str(aggregate_id),
        defaults={"name": name}
    )
```

### Pitfall 3: Business Logic in Projection
❌ **Wrong:**
```python
@process_event.register
def _(self, event: MyAggregate.Created, tracking: Tracking) -> None:
    if event.field1.startswith("special_"):
        category = "special"
    else:
        category = "normal"
    self.view.create_entity(category=category)  # Logic in projection!
```

✅ **Correct:**
```python
# Put logic in aggregate/command handler:
class MyAggregate(Aggregate):
    class Created(Aggregate.Created):
        category: str  # Computed before event

# Projection just maps:
@process_event.register
def _(self, event: MyAggregate.Created, tracking: Tracking) -> None:
    self.view.create_entity(category=event.category)
```

# Examples

## Example 1: GitHub Installation Projection

**User Request:** "Create projection for GitHub installations to power the API"

**Actions Taken:**
1. Fetched eventsourcing projection documentation
2. Created `read_model_interface.py` with interface
3. Created `projection.py` subscribing to installation events
4. Created `django_read_model.py` implementing Django operations
5. Registered projection in projection runner
6. Wrote tests with mock read model
7. Ran tests - all passing

**Code Created:**
```python
# read_model_interface.py
from abc import ABC, abstractmethod
from uuid import UUID

class InstallationReadModelInterface(ABC):
    @abstractmethod
    def create_installation(
        self,
        aggregate_id: UUID,
        installation_id: int,
        account_login: str,
        tenant_id: str
    ) -> None:
        pass

    @abstractmethod
    def suspend_installation(self, aggregate_id: UUID) -> None:
        pass

# projection.py
class InstallationProjection(Projection[InstallationReadModelInterface]):
    name = "installation"

    topics = (
        get_topic(GitHubInstallation.Created),
        get_topic(GitHubInstallation.Suspended),
    )

    @process_event.register
    def _(self, event: GitHubInstallation.Created, tracking: Tracking) -> None:
        self.view.create_installation(
            aggregate_id=event.originator_id,
            installation_id=event.installation_id,
            account_login=event.account_login,
            tenant_id=event.tenant_id
        )

    @process_event.register
    def _(self, event: GitHubInstallation.Suspended, tracking: Tracking) -> None:
        self.view.suspend_installation(aggregate_id=event.originator_id)

# django_read_model.py
class DjangoInstallationReadModel(InstallationReadModelInterface, PostgresTrackingRecorder):
    def create_installation(
        self,
        aggregate_id: UUID,
        installation_id: int,
        account_login: str,
        tenant_id: str
    ) -> None:
        with transaction.atomic():
            GithubInstallation.objects.update_or_create(
                aggregate_id=str(aggregate_id),
                defaults={
                    "installation_id": installation_id,
                    "account_login": account_login,
                    "tenant_id": tenant_id,
                    "is_suspended": False,
                }
            )

    def suspend_installation(self, aggregate_id: UUID) -> None:
        with transaction.atomic():
            GithubInstallation.objects.filter(
                aggregate_id=str(aggregate_id)
            ).update(is_suspended=True)
```

**Expected Outcome:**
- Projection converts events to Django models
- API can query Django models for GET requests
- Tests verify event processing
- Projection runs in sidecar container

## Example 2: Repository Denormalization Projection

**User Request:** "Project repository events to separate read model for API"

**Code Created:**
```python
# Located at: apps/registry/github_integration/github_repository/

class GithubRepositoryProjection(Projection[GithubRepositoryReadModelInterface]):
    name = "github_repository"

    topics = (
        get_topic(GitHubInstallation.RepositoryAdded),
        get_topic(GitHubInstallation.RepositoryRemoved),
    )

    @process_event.register
    def _(self, event: GitHubInstallation.RepositoryAdded, tracking: Tracking) -> None:
        self.view.create_repository(
            installation_id=event.originator_id,
            repository_id=event.repository_id,
            repository_name=event.repository_name,
            repository_url=event.repository_url
        )

    @process_event.register
    def _(self, event: GitHubInstallation.RepositoryRemoved, tracking: Tracking) -> None:
        self.view.remove_repository(repository_id=event.repository_id)
```

**Expected Outcome:**
- Denormalized repository view from installation events
- API queries `GithubRepo` Django model
- Separate projection from `InstallationProjection`

# Supporting Documentation

For advanced projection patterns:
- [cross-aggregate-projections.md](cross-aggregate-projections.md) - Multi-aggregate projections
- [projection-testing.md](projection-testing.md) - Testing strategies
- [projection-runner.md](projection-runner.md) - Deployment and running

---

**Quick Decision Tree:**

```
What kind of projection do you need?

Single Aggregate Events → Django Model?
└─> Standard Projection (Pattern 1)

Multiple Events → Single Denormalized Model?
└─> Denormalization Projection (Pattern 2)

Events from Multiple Aggregates?
└─> Cross-Aggregate Projection (Pattern 4)

Filter Events by Condition?
└─> Filtering Projection (Pattern 3)
```

**Remember:** Projections are the ONLY way API endpoints should access data. Never query aggregates directly!
