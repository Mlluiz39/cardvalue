# Contracts

This directory defines the interface contracts between system boundaries:

| File | Scope |
|------|-------|
| `edge-functions.md` | Supabase Edge Function invocation contracts (input/output schemas) |
| `data-access-patterns.md` | Repository layer contracts between features and data sources |
| `navigation-routes.md` | GoRouter route definitions for feature navigation |
| `widget-contracts.md` | Shared widget parameter contracts |

These contracts follow the principle: define the boundary, then implement independently.
