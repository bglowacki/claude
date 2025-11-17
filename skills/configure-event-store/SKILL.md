---
name: Configure Event Store
description: |
  Configures PostgreSQL event store for Python eventsourcing library with proper persistence and snapshot strategies.
  Use this when: setting up event sourcing infrastructure, configuring persistence, or optimizing event store performance.
  Triggers: "configure event store", "setup persistence", "event store config", "PostgreSQL event store".
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, mcp__context7__resolve-library-id, mcp__context7__get-library-docs]
---

# Instructions

## Prerequisites
- PostgreSQL database installed and accessible
- Python eventsourcing library installed
- Django settings configured
- Understanding of event sourcing persistence

## Workflow

### Step 1: Fetch Eventsourcing Documentation

```python
# Resolve library ID
mcp__context7__resolve-library-id(libraryName="eventsourcing")

# Fetch persistence documentation
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/pyeventsourcing/eventsourcing",
    topic="persistence",
    page=1
)

# Fetch application documentation
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/pyeventsourcing/eventsourcing",
    topic="application",
    page=1
)
```

### Step 2: Configure Database Connection

**Django Settings Integration:**

Add to `settings.py`:

```python
# Event Store Configuration
EVENTSOURCING_DB = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
    "user": os.getenv("POSTGRES_USER", "postgres"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "database": os.getenv("POSTGRES_DB", "widget_service"),
}

# Event Store Connection String
EVENTSOURCING_CONNECTION_STRING = (
    f"postgresql://{EVENTSOURCING_DB['user']}:{EVENTSOURCING_DB['password']}"
    f"@{EVENTSOURCING_DB['host']}:{EVENTSOURCING_DB['port']}/{EVENTSOURCING_DB['database']}"
)
```

**Environment Variables** (`.env`):

```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=widget_service
```

### Step 3: Create Application Class

Configure the event sourcing application:

**File**: `apps/core/eventsourcing/application.py`

```python
import os
from eventsourcing.application import Application
from eventsourcing.postgres import Factory as PostgresFactory
from django.conf import settings

class WidgetServiceApplication(Application):
    def __init__(self):
        super().__init__(
            env={
                "PERSISTENCE_MODULE": "eventsourcing.postgres",
                "POSTGRES_DBNAME": settings.EVENTSOURCING_DB["database"],
                "POSTGRES_HOST": settings.EVENTSOURCING_DB["host"],
                "POSTGRES_PORT": str(settings.EVENTSOURCING_DB["port"]),
                "POSTGRES_USER": settings.EVENTSOURCING_DB["user"],
                "POSTGRES_PASSWORD": settings.EVENTSOURCING_DB["password"],
                # Optional: Enable snapshots
                "IS_SNAPSHOTTING_ENABLED": "y",
                "SNAPSHOT_INTERVAL": "10",  # Snapshot every 10 events
            }
        )

    def create_aggregate(self, aggregate_class, *args, **kwargs):
        aggregate = aggregate_class.create(*args, **kwargs)
        self.save(aggregate)
        return aggregate

    def update_aggregate(self, aggregate_id, aggregate_class, update_func):
        aggregate = self.repository.get(aggregate_id)
        update_func(aggregate)
        self.save(aggregate)
        return aggregate
```

### Step 4: Initialize Event Store Tables

Create database tables for event storage:

**Migration Command:**

```python
# apps/core/management/commands/init_event_store.py
from django.core.management.base import BaseCommand
from eventsourcing.postgres import Factory as PostgresFactory
from django.conf import settings

class Command(BaseCommand):
    help = "Initialize event store tables in PostgreSQL"

    def handle(self, *args, **options):
        factory = PostgresFactory(
            dbname=settings.EVENTSOURCING_DB["database"],
            host=settings.EVENTSOURCING_DB["host"],
            port=settings.EVENTSOURCING_DB["port"],
            user=settings.EVENTSOURCING_DB["user"],
            password=settings.EVENTSOURCING_DB["password"],
        )

        with factory.datastore.get_connection() as conn:
            factory.datastore.create_table(conn)
            self.stdout.write(self.style.SUCCESS("Event store tables created"))
```

**Run Initialization:**

```bash
python manage.py init_event_store
```

### Step 5: Configure Repository Access

Create repository wrapper for dependency injection:

**File**: `apps/core/eventsourcing/repository.py`

```python
from typing import TypeVar, Generic
from uuid import UUID
from eventsourcing.domain import Aggregate
from .application import WidgetServiceApplication

T = TypeVar("T", bound=Aggregate)

class EventSourcedRepository(Generic[T]):
    def __init__(self, application: WidgetServiceApplication, aggregate_class: type[T]):
        self.application = application
        self.aggregate_class = aggregate_class

    def get(self, aggregate_id: UUID) -> T:
        return self.application.repository.get(aggregate_id)

    def save(self, aggregate: T) -> None:
        self.application.save(aggregate)

    def exists(self, aggregate_id: UUID) -> bool:
        try:
            self.get(aggregate_id)
            return True
        except Exception:
            return False
```

### Step 6: Configure Snapshot Strategy (Optional)

For aggregates with long event histories, configure snapshots:

**Snapshot Settings:**

```python
# In Application __init__
env={
    # Enable snapshots
    "IS_SNAPSHOTTING_ENABLED": "y",

    # Snapshot every N events (default: 10)
    "SNAPSHOT_INTERVAL": "10",

    # Max snapshots to keep per aggregate
    "MAX_SNAPSHOTS": "5",
}
```

**When to Use Snapshots:**
- Aggregates with >100 events
- Frequent aggregate loading
- Performance-critical operations
- Long-lived aggregates

**Snapshot Trade-offs:**
- ✅ Faster aggregate reconstruction
- ✅ Reduced database queries
- ❌ Additional storage
- ❌ Snapshot versioning complexity

### Step 7: Configure Event Notification (For Projections)

Set up notification for projection runners:

**File**: `apps/core/eventsourcing/notifications.py`

```python
from eventsourcing.domain import DomainEvent
from typing import Callable

class EventNotifier:
    def __init__(self):
        self.subscribers: list[Callable[[DomainEvent], None]] = []

    def subscribe(self, handler: Callable[[DomainEvent], None]) -> None:
        self.subscribers.append(handler)

    def publish(self, event: DomainEvent) -> None:
        for subscriber in self.subscribers:
            try:
                subscriber(event)
            except Exception as e:
                # Log error but don't fail event storage
                print(f"Notification error: {e}")

# Global notifier instance
event_notifier = EventNotifier()
```

### Step 8: Test Event Store Configuration

Create tests to verify setup:

**File**: `apps/core/tests/test_event_store.py`

```python
import pytest
from uuid import uuid4
from apps.core.eventsourcing.application import WidgetServiceApplication
from apps.registry.widget_registry_endpoint.aggregate import WidgetRegistryEndpoint

@pytest.fixture
def application():
    return WidgetServiceApplication()

def test_event_store_save_and_load(application):
    # Create aggregate
    endpoint = WidgetRegistryEndpoint.create(
        url="https://example.com",
        name="Test Endpoint",
        tenant_id="tenant-123"
    )

    # Save to event store
    application.save(endpoint)

    # Load from event store
    loaded = application.repository.get(endpoint.id)

    assert loaded.id == endpoint.id
    assert loaded.url == endpoint.url
    assert loaded.name == endpoint.name
    assert loaded.tenant_id == endpoint.tenant_id

def test_event_store_event_persistence(application):
    # Create and modify aggregate
    endpoint = WidgetRegistryEndpoint.create(
        url="https://example.com",
        name="Test",
        tenant_id="tenant-123"
    )
    application.save(endpoint)

    loaded = application.repository.get(endpoint.id)
    loaded.update_name("Updated Name")
    application.save(loaded)

    # Reload and verify
    reloaded = application.repository.get(endpoint.id)
    assert reloaded.name == "Updated Name"

def test_snapshot_creation(application):
    # Create aggregate and trigger many events
    endpoint = WidgetRegistryEndpoint.create(
        url="https://example.com",
        name="Test",
        tenant_id="tenant-123"
    )

    # Trigger 15 events (should create snapshot at 10)
    for i in range(15):
        endpoint.update_name(f"Name {i}")

    application.save(endpoint)

    # Verify can still load correctly
    loaded = application.repository.get(endpoint.id)
    assert loaded.name == "Name 14"
```

## Event Store Configuration Patterns

### Pattern 1: Basic PostgreSQL Configuration

Minimal setup for development:

```python
class SimpleApplication(Application):
    def __init__(self):
        super().__init__(
            env={
                "PERSISTENCE_MODULE": "eventsourcing.postgres",
                "POSTGRES_DBNAME": "widget_service",
                "POSTGRES_HOST": "localhost",
                "POSTGRES_USER": "postgres",
                "POSTGRES_PASSWORD": "password",
            }
        )
```

### Pattern 2: Production Configuration with Snapshots

Optimized for production workloads:

```python
class ProductionApplication(Application):
    def __init__(self):
        super().__init__(
            env={
                "PERSISTENCE_MODULE": "eventsourcing.postgres",
                "POSTGRES_DBNAME": os.getenv("POSTGRES_DB"),
                "POSTGRES_HOST": os.getenv("POSTGRES_HOST"),
                "POSTGRES_PORT": os.getenv("POSTGRES_PORT", "5432"),
                "POSTGRES_USER": os.getenv("POSTGRES_USER"),
                "POSTGRES_PASSWORD": os.getenv("POSTGRES_PASSWORD"),
                "IS_SNAPSHOTTING_ENABLED": "y",
                "SNAPSHOT_INTERVAL": "10",
                "CREATE_TABLE": "n",  # Tables created via migration
                "POOL_SIZE": "20",  # Connection pool size
                "POOL_MAX_OVERFLOW": "10",
            }
        )
```

### Pattern 3: Multi-Tenant Configuration

Separate event stores per tenant:

```python
class MultiTenantApplication(Application):
    def __init__(self, tenant_id: str):
        super().__init__(
            env={
                "PERSISTENCE_MODULE": "eventsourcing.postgres",
                "POSTGRES_DBNAME": f"tenant_{tenant_id}",
                "POSTGRES_HOST": os.getenv("POSTGRES_HOST"),
                "POSTGRES_USER": os.getenv("POSTGRES_USER"),
                "POSTGRES_PASSWORD": os.getenv("POSTGRES_PASSWORD"),
            }
        )
        self.tenant_id = tenant_id
```

### Pattern 4: Testing Configuration (SQLite)

Fast in-memory for tests:

```python
class TestApplication(Application):
    def __init__(self):
        super().__init__(
            env={
                "PERSISTENCE_MODULE": "eventsourcing.sqlite",
                "SQLITE_DBNAME": ":memory:",  # In-memory database
            }
        )
```

## Best Practices

### DO:
✅ **Use environment variables** - Never hardcode credentials
✅ **Enable snapshots** - For aggregates with many events
✅ **Test configuration** - Verify event storage/retrieval
✅ **Use connection pooling** - For production deployments
✅ **Create tables via migration** - Don't auto-create in production
✅ **Monitor event store** - Track storage growth, query performance
✅ **Backup event store** - Critical business data

### DON'T:
❌ **Don't commit credentials** - Use environment variables
❌ **Don't skip snapshots** - Performance degrades with long histories
❌ **Don't auto-create tables in production** - Use migrations
❌ **Don't ignore connection limits** - Configure pool size
❌ **Don't forget indexes** - Event queries need indexes
❌ **Don't skip backups** - Event store is source of truth

## Common Pitfalls

### Pitfall 1: Missing Environment Variables
❌ **Wrong:**
```python
env={
    "POSTGRES_PASSWORD": "hardcoded_password",  # ❌ Security risk
}
```

✅ **Correct:**
```python
env={
    "POSTGRES_PASSWORD": os.getenv("POSTGRES_PASSWORD"),
}
```

### Pitfall 2: No Snapshot Configuration
❌ **Wrong:**
```python
# Long-lived aggregate with hundreds of events
# No snapshots configured
```

✅ **Correct:**
```python
env={
    "IS_SNAPSHOTTING_ENABLED": "y",
    "SNAPSHOT_INTERVAL": "10",  # Snapshot every 10 events
}
```

### Pitfall 3: Missing Connection Pool
❌ **Wrong:**
```python
# Default connection settings for high-load production
```

✅ **Correct:**
```python
env={
    "POOL_SIZE": "20",
    "POOL_MAX_OVERFLOW": "10",
    "POOL_PRE_PING": "y",  # Verify connections before use
}
```

## Performance Optimization

### Database Indexes

Create indexes for common queries:

```sql
-- Index on aggregate ID for fast lookups
CREATE INDEX idx_events_originator_id ON stored_events (originator_id);

-- Index on timestamp for time-based queries
CREATE INDEX idx_events_timestamp ON stored_events (timestamp);

-- Index for event notifications
CREATE INDEX idx_events_notification_id ON stored_events (notification_id);
```

### Connection Pooling

Configure appropriate pool sizes:

```python
env={
    "POOL_SIZE": "20",  # Base connection pool size
    "POOL_MAX_OVERFLOW": "10",  # Additional connections under load
    "POOL_TIMEOUT": "30",  # Timeout waiting for connection
    "POOL_RECYCLE": "3600",  # Recycle connections hourly
}
```

### Snapshot Tuning

Adjust snapshot frequency based on aggregate characteristics:

```python
# High-frequency aggregates (many events)
"SNAPSHOT_INTERVAL": "5"  # Snapshot more frequently

# Low-frequency aggregates
"SNAPSHOT_INTERVAL": "20"  # Snapshot less frequently

# Very long-lived aggregates
"SNAPSHOT_INTERVAL": "10"
"MAX_SNAPSHOTS": "10"  # Keep more snapshots
```

## Monitoring and Maintenance

### Event Store Metrics

Monitor key metrics:

- Event storage rate (events/second)
- Aggregate reconstruction time
- Database size growth
- Snapshot creation rate
- Query performance (p95, p99)

### Maintenance Tasks

Regular maintenance:

1. **Archive old events** - Move historical events to cold storage
2. **Clean old snapshots** - Remove superseded snapshots
3. **Vacuum database** - PostgreSQL maintenance
4. **Monitor indexes** - Ensure queries are optimized
5. **Test backups** - Verify restore procedures

# Examples

## Example 1: Django Integration

**Configure event store in Django project:**

```python
# settings.py
EVENTSOURCING_DB = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "database": os.getenv("POSTGRES_DB"),
}

# apps/core/eventsourcing/application.py
class WidgetServiceApplication(Application):
    def __init__(self):
        super().__init__(
            env={
                "PERSISTENCE_MODULE": "eventsourcing.postgres",
                "POSTGRES_DBNAME": settings.EVENTSOURCING_DB["database"],
                "POSTGRES_HOST": settings.EVENTSOURCING_DB["host"],
                "POSTGRES_PORT": str(settings.EVENTSOURCING_DB["port"]),
                "POSTGRES_USER": settings.EVENTSOURCING_DB["user"],
                "POSTGRES_PASSWORD": settings.EVENTSOURCING_DB["password"],
                "IS_SNAPSHOTTING_ENABLED": "y",
                "SNAPSHOT_INTERVAL": "10",
            }
        )
```

## Example 2: Production Configuration

**Production-ready setup with all optimizations:**

```python
class ProductionApplication(Application):
    def __init__(self):
        super().__init__(
            env={
                # Database connection
                "PERSISTENCE_MODULE": "eventsourcing.postgres",
                "POSTGRES_DBNAME": os.getenv("POSTGRES_DB"),
                "POSTGRES_HOST": os.getenv("POSTGRES_HOST"),
                "POSTGRES_PORT": os.getenv("POSTGRES_PORT", "5432"),
                "POSTGRES_USER": os.getenv("POSTGRES_USER"),
                "POSTGRES_PASSWORD": os.getenv("POSTGRES_PASSWORD"),

                # Snapshots
                "IS_SNAPSHOTTING_ENABLED": "y",
                "SNAPSHOT_INTERVAL": "10",
                "MAX_SNAPSHOTS": "5",

                # Connection pooling
                "POOL_SIZE": "20",
                "POOL_MAX_OVERFLOW": "10",
                "POOL_TIMEOUT": "30",
                "POOL_PRE_PING": "y",

                # Performance
                "CREATE_TABLE": "n",  # Use migrations
            }
        )
```

## Example 3: Testing Configuration

**Fast configuration for unit tests:**

```python
# conftest.py
import pytest
from eventsourcing.application import Application

@pytest.fixture
def application():
    return Application(
        env={
            "PERSISTENCE_MODULE": "eventsourcing.sqlite",
            "SQLITE_DBNAME": ":memory:",
        }
    )

def test_with_event_store(application):
    # Tests run with in-memory SQLite
    pass
```

# Quick Reference

**Configuration Checklist:**
- [ ] PostgreSQL connection configured
- [ ] Environment variables set
- [ ] Snapshots enabled (if needed)
- [ ] Connection pooling configured
- [ ] Tables created via migration
- [ ] Tests verify storage/retrieval
- [ ] Monitoring in place

**Performance Checklist:**
- [ ] Appropriate snapshot interval
- [ ] Connection pool sized correctly
- [ ] Database indexes created
- [ ] Backup strategy defined
- [ ] Monitoring configured

**Security Checklist:**
- [ ] Credentials in environment variables
- [ ] No hardcoded passwords
- [ ] SSL/TLS for database connection
- [ ] Principle of least privilege
- [ ] Regular backups tested
