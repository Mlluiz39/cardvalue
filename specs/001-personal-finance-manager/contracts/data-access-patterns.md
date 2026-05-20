# Data Access Patterns

## Repository Layer Contract

Each feature follows this pattern:

```
features/{feature}/
├── data/
│   ├── local/
│   │   └── {feature}_local_ds.dart    // Drift SQLite queries
│   ├── remote/
│   │   └── {feature}_remote_ds.dart   // Supabase API calls
│   └── repository/
│       └── {feature}_repository.dart  // Combines local + remote
├── domain/
│   └── models/
│       └── {entity}.dart              // Domain models
└── presentation/
    └── ...
```

## Repository Contract (interface)

Every repository exposes:

```dart
abstract class CardRepository {
  Stream<List<Card>> watchAll();                   // reactive stream
  Future<Card> getById(String id);
  Future<Card> create(Card card);
  Future<Card> update(Card card);
  Future<void> delete(String id);
}
```

## Sync Strategy

```
READ:    LocalDS.stream() ──→ UI (instant)
         RemoteDS.fetch() ──→ LocalDS.upsert() ──→ UI updates via stream

WRITE:   LocalDS.upsert() ──→ UI updates immediately (optimistic)
         RemoteDS.upsert() ──→ on success: mark synced
                           ──→ on failure: keep in outbox, retry
```

## Outbox Table (sync queue)

```sql
CREATE TABLE sync_outbox (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
  payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'syncing', 'failed')),
  retry_count INTEGER DEFAULT 0,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

## Offline Data Lifecycle

1. **App launch**: Drift DB opened, data streamed to UI
2. **Online**: Supabase fetch triggered, results upserted to Drift
3. **Offline writes**: Written to Drift + outbox table
4. **Reconnect**: SyncService processes outbox, retries failed, marks synced
5. **Cache invalidation**: Drift keeps last N months; older data evicted on full sync
